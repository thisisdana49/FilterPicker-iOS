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
    private var isRefreshing = false
    private var refreshTask: Task<TokenResponse, Error>?
    private let maxRetryCount = 1
    
    init() {}

    func request<T: Decodable>(_ request: APIRequest) async throws -> T {
        return try await performRequest(request, retryCount: 0)
    }
    
    private func performRequest<T: Decodable>(_ request: APIRequest, retryCount: Int) async throws -> T {
        guard let urlRequest = makeURLRequest(from: request) else {
            throw NetworkError.invalidRequest
        }

        // MARK: - 🔍 로그 요청 출력
        print("🌐 [Request] \(request.method.rawValue) \(request.path)")
        if let body = request.body {
            print("📤 Body: \(body)")
        }
        
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

        // 419 응답 처리 (액세스 토큰 만료)
        if httpResponse.statusCode == 419 {
            // 토큰 갱신 시도
            if retryCount < maxRetryCount {
                do {
                    let newTokens = try await refreshToken()
                    TokenStorage.accessToken = newTokens.accessToken
                    TokenStorage.refreshToken = newTokens.refreshToken
                    
                    // 새로운 토큰으로 요청 재시도
                    return try await performRequest(request, retryCount: retryCount + 1)
                } catch {
                    // 토큰 갱신 실패 시 로그아웃 처리
                    TokenStorage.clear()
                    throw AuthError.expiredRefreshToken
                }
            } else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }
        }
        
        // 403 응답 처리 (권한 없음 - 탈퇴한 회원, 접근 권한 없음 등)
        if httpResponse.statusCode == 403 {
            print("❌ 403 Forbidden: 접근 권한이 없습니다. (탈퇴한 회원이거나 권한 부족)")
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decoding(error)
        }
    }
    
    private func refreshToken() async throws -> TokenResponse {
        // 이미 토큰 갱신 중인 경우 기존 작업 재사용
        if let existingTask = refreshTask {
            return try await existingTask.value
        }
        
        // 새로운 토큰 갱신 작업 생성
        let task = Task<TokenResponse, Error> {
            defer {
                refreshTask = nil
                isRefreshing = false
            }
            
            isRefreshing = true
            
            // 토큰 갱신 API 직접 호출
            let request = APIRequest(
                path: "/v1/auth/refresh",
                method: .get,
                headers: [
                    "RefreshToken": TokenStorage.refreshToken ?? "",
                    "Authorization": TokenStorage.accessToken ?? ""
                ]
            )
            
            return try await self.request(request)
        }
        
        refreshTask = task
        return try await task.value
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
        
        // 로그인 상태인 경우 Authorization 헤더 추가
        if let accessToken = TokenStorage.accessToken,
           !TokenStorage.isAccessTokenExpired() {
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
