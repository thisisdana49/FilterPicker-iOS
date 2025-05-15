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

    func request<T: Decodable>(_ request: APIRequest) async throws -> T {
        guard let urlRequest = makeURLRequest(from: request) else {
            throw NetworkError.invalidRequest
        }

        // MARK: - 🔍 로그 요청 출력
        print("🌐 [Request] \(request.method.rawValue) \(request.path)")
        if let body = request.body {
            print("📤 Body: \(body)")
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

        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "SesacKey")

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
