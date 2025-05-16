//
//  AuthReducer.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

struct AuthReducer {
    private let authRepository: AuthRepository
    private let appStore: AppStore

    init(
        authRepository: AuthRepository = DefaultAuthRepository(),
        appStore: AppStore
    ) {
        self.authRepository = authRepository
        self.appStore = appStore
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
                print("\n🔐 로그인 성공 - 토큰 저장")
                TokenStorage.accessToken = token.accessToken
                TokenStorage.refreshToken = token.refreshToken
                
                // 토큰 만료 시간 설정 (현재 시간 + 2분)
                TokenStorage.accessTokenExpiration = Date().addingTimeInterval(120)
                // 리프레시 토큰 만료 시간 설정 (현재 시간 + 5분)
                TokenStorage.refreshTokenExpiration = Date().addingTimeInterval(300)
                
                TokenStorage.printTokenStatus()
                
                newState.isLoggedIn = true
                newState.isLoading = false
                await appStore.send(.loginSucceeded)
            } catch {
                print("❌ login error:", error)
                newState.errorMessage = "로그인에 실패했습니다."
                newState.isLoading = false
                await appStore.send(.loginFailed("로그인에 실패했습니다."))
            }

        case .loginSucceeded:
            newState.isLoggedIn = true

        case .loginFailed(let message):
            newState.errorMessage = message
        }

        return newState
    }
}
