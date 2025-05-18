//
//  AuthRepository.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

protocol AuthRepository {
    func signup(email: String, password: String, nickname: String) async throws -> AuthTokenResponse
    func login(email: String, password: String) async throws -> AuthTokenResponse
    func refreshToken() async throws -> TokenResponse
}

final class DefaultAuthRepository: AuthRepository {
    private let apiService: APIService

    init(apiService: APIService = DefaultAPIService()) {
        self.apiService = apiService
    }

    func signup(email: String, password: String, nickname: String) async throws -> AuthTokenResponse {
        let request = APIRequest(
            path: "/v1/users/join",
            method: .post,
            body: [
                "email": email,
                "password": password,
                "nickname": nickname
            ]
        )

        let response: AuthTokenResponse = try await apiService.request(request)
        return response
    }

    func login(email: String, password: String) async throws -> AuthTokenResponse {
        let request = APIRequest(
            path: "/v1/users/login",
            method: .post,
            body: [
                "email": email,
                "password": password
            ]
        )

        let response: AuthTokenResponse = try await apiService.request(request)
        return response
    }
    
    func refreshToken() async throws -> TokenResponse {
        guard let refreshToken = TokenStorage.refreshToken else {
            print("❌ RefreshToken이 없습니다.")
            throw AuthError.invalidRefreshToken
        }
        
        let request = APIRequest(
            path: "/v1/auth/refresh",
            method: .get,
            headers: [
                "RefreshToken": refreshToken,
                "Authorization": TokenStorage.accessToken ?? ""
            ]
        )
        
        do {
            let response: TokenResponse = try await apiService.request(request)
            print("✅ 토큰 갱신 성공")
            return response
        } catch let error as NetworkError {
            switch error {
            case .statusCode(401):
                print("❌ 인증할 수 없는 리프레시 토큰")
                throw AuthError.invalidRefreshToken
            case .statusCode(418):
                print("❌ 리프레시 토큰 만료")
                throw AuthError.expiredRefreshToken
            case .invalidRequest, .invalidResponse, .decoding:
                print("❌ 네트워크 오류")
                throw AuthError.networkError
            case .statusCode:
                print("❌ 알 수 없는 오류")
                throw AuthError.unknownError
            }
        } catch {
            print("❌ 네트워크 오류:", error.localizedDescription)
            throw AuthError.networkError
        }
    }
}
