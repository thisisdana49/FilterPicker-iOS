//
//  AuthReducer.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

struct AuthReducer {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = DefaultAuthRepository()) {
        self.authRepository = authRepository
    }

    func reduce(state: AuthState, intent: AuthIntent) async -> AuthState {
        var newState = state

        switch intent {
        case .emailChanged(let email):
            newState.email = email

        case .passwordChanged(let password):
            newState.password = password

        case .loginTapped:
            newState.isLoading = true
            do {
                let token = try await authRepository.login(
                    email: state.email,
                    password: state.password
                )
                TokenStorage.accessToken = token.accessToken
                TokenStorage.refreshToken = token.refreshToken
                newState.isLoggedIn = true
                newState.isLoading = false
            } catch {
                print("❌ login error:", error)
                newState.errorMessage = "로그인에 실패했습니다."
                newState.isLoading = false
            }

        case .loginSucceeded:
            newState.isLoggedIn = true

        case .loginFailed(let message):
            newState.errorMessage = message
        }

        return newState
    }
}
