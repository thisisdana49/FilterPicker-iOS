//
//  APIService.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

protocol APIService {
    func request<T: Decodable>(_ request: APIRequest) async throws -> T
}

final class DefaultAPIService: APIService {
    private var refreshTask: Task<TokenResponse, Error>?
    
    init() {}

    func request<T: Decodable>(_ request: APIRequest) async throws -> T {
        // 1. 토큰이 1분 내 만료되는지 체크하고 필요시 미리 갱신
        if TokenStorage.shouldRefreshAccessToken() && !TokenStorage.isRefreshTokenExpired() {
            print("🔄 [Proactive] 토큰이 1분 내 만료 예정 - 미리 갱신 시작")
            try await ensureValidToken()
        }
        
        return try await performRequest(request)
    }
    
    private func performRequest<T: Decodable>(_ request: APIRequest) async throws -> T {
        guard let urlRequest = makeURLRequest(from: request) else {
            throw NetworkError.invalidRequest
        }

        // MARK: - 🔍 로그 요청 출력
        print("🌐 [Request] \(request.method.rawValue) \(request.path)")
        if let body = request.body {
            print("📤 Body: \(body)")
        }
        
        // CURL 명령어 출력
        print("🐚 [CURL] \(urlRequest.curlString)")
        
        // 토큰 상태 로그
        if let accessToken = TokenStorage.accessToken {
            let isExpired = TokenStorage.isAccessTokenExpired()
            print("🔑 AccessToken: \(isExpired ? "만료됨" : "유효함")")
        } else {
            print("🚫 AccessToken: 없음")
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // MARK: - 🔍 로그 응답 출력
        print("📬 [Response] Status: \(httpResponse.statusCode)")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Data: \(jsonString)")
        }

        // 상태코드별 처리 디버깅
        print("🔍 [Debug] 상태코드 체크 시작: \(httpResponse.statusCode)")
        
        // 429 응답 처리 (Too Many Requests)
        if httpResponse.statusCode == 429 {
            print("⚠️ [Debug] 429 Too Many Requests! API 호출 횟수 초과")
            if let rateLimitHeader = httpResponse.allHeaderFields["X-RateLimit-Limit"] {
                print("    Rate Limit: \(rateLimitHeader)")
            }
            if let resetTimeHeader = httpResponse.allHeaderFields["X-RateLimit-Reset"] {
                print("    Reset Time: \(resetTimeHeader)")
            }
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        
        // 419 응답 처리 (액세스 토큰 만료 - Reactive 처리)
        if httpResponse.statusCode == 419 {
            print("⚠️ [Reactive] 419 응답: AccessToken 만료 감지")
            
            // Reactive 토큰 갱신 후 재시도
            try await ensureValidToken()
            return try await performRequest(request)
        }
        
        // 403 응답 처리 (권한 없음 - 탈퇴한 회원, 접근 권한 없음 등)
        if httpResponse.statusCode == 403 {
            print("❌ [Debug] 403 조건문 진입! Forbidden: 접근 권한이 없습니다. (탈퇴한 회원이거나 권한 부족)")
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        // 다른 에러 상태코드 체크
        if !(200..<300 ~= httpResponse.statusCode) {
            print("❌ [Debug] 비정상 상태코드 감지: \(httpResponse.statusCode)")
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        print("✅ [Debug] 정상 응답 처리 시작")

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decoding(error)
        }
    }
    
    private func ensureValidToken() async throws {
        // 이미 토큰 갱신 중인 경우 기존 작업 재사용
        if let existingTask = refreshTask {
            _ = try await existingTask.value
            return
        }
        
        // 새로운 토큰 갱신 작업 생성
        let task = Task<TokenResponse, Error> {
            defer {
                refreshTask = nil
            }
            
            return try await refreshToken()
        }
        
        refreshTask = task
        let newTokens = try await task.value
        
        // 새로운 토큰 저장
        TokenStorage.accessToken = newTokens.accessToken
        TokenStorage.refreshToken = newTokens.refreshToken
        
        print("✅ [TokenRefresh] 토큰 갱신 완료")
    }
    
    private func refreshToken() async throws -> TokenResponse {
        print("🔑 [TokenRefresh] Refresh Token 갱신 시작")
        TokenStorage.printTokenStatus()
        
        guard let refreshToken = TokenStorage.refreshToken else {
            print("❌ [TokenRefresh] RefreshToken이 없습니다")
            throw AuthError.invalidRefreshToken
        }
        
        guard !TokenStorage.isRefreshTokenExpired() else {
            print("❌ [TokenRefresh] RefreshToken이 만료되었습니다")
            TokenStorage.clear()
            throw AuthError.expiredRefreshToken
        }
        
        guard let url = URL(string: AppConfig.baseURL + "/v1/auth/refresh") else {
            print("❌ [TokenRefresh] 잘못된 URL")
            throw NetworkError.invalidRequest
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "SesacKey")
        urlRequest.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
        urlRequest.setValue(TokenStorage.accessToken ?? "", forHTTPHeaderField: "Authorization")
        
        print("🔄 [TokenRefresh] 요청 헤더:")
        print("    SesacKey: \(AppConfig.apiKey)")
        print("    RefreshToken: \(String(refreshToken.prefix(20)))...")
        print("    Authorization: \(String((TokenStorage.accessToken ?? "").prefix(20)))...")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [TokenRefresh] 잘못된 응답 형식")
            throw NetworkError.invalidResponse
        }
        
        print("🔄 [TokenRefresh] 응답 상태: \(httpResponse.statusCode)")
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🔄 [TokenRefresh] 응답 데이터: \(jsonString)")
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            if httpResponse.statusCode == 418 {
                print("❌ [TokenRefresh] RefreshToken 만료 (418)")
                TokenStorage.clear()
                throw AuthError.expiredRefreshToken
            } else if httpResponse.statusCode == 403 {
                print("❌ [TokenRefresh] 권한 없음 (403) - 헤더 확인 필요")
                TokenStorage.clear()
                throw AuthError.invalidRefreshToken
            } else if httpResponse.statusCode == 401 {
                print("❌ [TokenRefresh] 인증 실패 (401) - 유효하지 않은 RefreshToken")
                TokenStorage.clear()
                throw AuthError.invalidRefreshToken
            } else {
                print("❌ [TokenRefresh] HTTP 에러: \(httpResponse.statusCode)")
                throw NetworkError.statusCode(httpResponse.statusCode)
            }
        }
        
        do {
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            print("✅ [TokenRefresh] 토큰 갱신 성공")
            print("✅ [TokenRefresh] 새 AccessToken: \(tokenResponse.accessToken.prefix(20))...")
            print("✅ [TokenRefresh] 새 RefreshToken: \(tokenResponse.refreshToken.prefix(20))...")
            return tokenResponse
        } catch {
            print("❌ [TokenRefresh] 디코딩 실패: \(error)")
            throw NetworkError.decoding(error)
        }
    }
}

private extension DefaultAPIService {
    func makeURLRequest(from request: APIRequest) -> URLRequest? {
        var urlComponents = URLComponents(string: AppConfig.baseURL + request.path)
        if let queryParameters = request.queryParameters {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents?.url else { return nil }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        // 기본 헤더 설정
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "SesacKey")
        
        // 로그인 상태인 경우 Authorization 헤더 추가 (만료된 토큰이라도 서버에서 판단할 수 있도록 전송)
        if let accessToken = TokenStorage.accessToken {
            urlRequest.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }

        // 사용자 정의 헤더
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = request.body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }

        return urlRequest
    }
}

// MARK: - URLRequest CURL Extension
//extension URLRequest {
//    var curlString: String {
//        guard let url = self.url else { return "❌ Invalid URL" }
//        
//        var curlCommand = "curl -X \(self.httpMethod ?? "GET")"
//        
//        // URL 추가
//        curlCommand += " '\(url.absoluteString)'"
//        
//        // 헤더 추가
//        if let headers = self.allHTTPHeaderFields {
//            for (key, value) in headers {
//                curlCommand += " \\\n  -H '\(key): \(value)'"
//            }
//        }
//        
//        // Body 추가 (있는 경우)
//        if let httpBody = self.httpBody,
//           let bodyString = String(data: httpBody, encoding: .utf8) {
//            curlCommand += " \\\n  -d '\(bodyString)'"
//        }
//        
//        return curlCommand
//    }
//}
