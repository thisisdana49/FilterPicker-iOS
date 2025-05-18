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
            newState.errorMessage = nil
            do {
                let response = try await authRepository.login(
                    email: state.email,
                    password: state.password
                )
                TokenStorage.accessToken = response.accessToken
                TokenStorage.refreshToken = response.refreshToken
                newState.isLoggedIn = true
                newState.isLoading = false
            } catch {
                newState.errorMessage = error.localizedDescription
                newState.isLoading = false
                await appStore.send(.loginFailed("로그인에 실패했습니다."))
            }

        case .loginSucceeded(let response):
            TokenStorage.accessToken = response.accessToken
            TokenStorage.refreshToken = response.refreshToken
            newState.isLoggedIn = true
            newState.isLoading = false
            
            await appStore.send(.loginSucceeded)

        case .loginFailed(let message):
            newState.errorMessage = message
            newState.isLoading = false

        case .appleLoginTapped:
            // Apple 로그인 버튼 탭 시 처리 (SignInWithAppleButton에서 처리)
            break

        case .appleLoginSucceeded(let idToken, let nick):
            newState.isLoading = true
            newState.errorMessage = nil
            do {
                let response = try await authRepository.loginWithApple(
                    idToken: idToken,
                    deviceToken: nil,
                    nick: nick
                )
                TokenStorage.accessToken = response.accessToken
                TokenStorage.refreshToken = response.refreshToken
                newState.isLoggedIn = true
                newState.isLoading = false
            } catch let error as AuthError {
                newState.errorMessage = error.errorDescription
                newState.isLoading = false
            } catch {
                newState.errorMessage = "로그인에 실패했습니다."
                newState.isLoading = false
            }

            await appStore.send(.loginSucceeded)

        case .appleLoginFailed(let message):
            newState.errorMessage = message
            newState.isLoading = false
            
        case .kakaoLoginTapped:
            // 카카오 로그인 버튼 탭 시 처리 (KakaoSDK에서 처리)
            break
            
        case .kakaoLoginSucceeded(let accessToken, let nick):
            newState.isLoading = true
            newState.errorMessage = nil
            do {
                let response = try await authRepository.loginWithKakao(
                    oauthToken: accessToken,
                    deviceToken: nil // TODO: 실제 DeviceToken으로 수정 필요
                )
                TokenStorage.accessToken = response.accessToken
                TokenStorage.refreshToken = response.refreshToken
                newState.isLoggedIn = true
                newState.isLoading = false
            } catch let error as AuthError {
                newState.errorMessage = error.errorDescription
                newState.isLoading = false
            } catch {
                newState.errorMessage = "로그인에 실패했습니다."
                newState.isLoading = false
            }
            
            await appStore.send(.loginSucceeded)
            
        case .kakaoLoginFailed(let message):
            newState.errorMessage = message
            newState.isLoading = false
        }

        return newState
    }
}
