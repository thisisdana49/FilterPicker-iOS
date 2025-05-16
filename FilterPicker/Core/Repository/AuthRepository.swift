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
            throw AuthError.noRefreshToken
        }
        
        let request = APIRequest(
            path: "/v1/auth/refresh",
            method: .get,
            headers: [
                "RefreshToken": refreshToken,
                "Authorization": TokenStorage.accessToken ?? ""
            ]
        )
        
        let response: TokenResponse = try await apiService.request(request)
        return response
    }
}

enum AuthError: Error {
    case noRefreshToken
    case refreshTokenExpired
    case refreshFailed
}
