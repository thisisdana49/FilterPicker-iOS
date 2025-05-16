//
//  AppReducer.swift
//  FilterPicker
//
//  Created by 조다은 on 5/16/25.
//

import Foundation

struct AppReducer {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository = DefaultAuthRepository()) {
        self.authRepository = authRepository
    }
    
    func reduce(state: AppState, intent: AppIntent) async -> AppState {
        var newState = state
        
        switch intent {
        case .checkAutoLogin:
            print("\n🔄 자동 로그인 체크 시작")
            TokenStorage.printTokenStatus()
            
            if let accessToken = TokenStorage.accessToken {
                if TokenStorage.isAccessTokenExpired() {
                    print("⚠️ AccessToken이 만료되어 갱신을 시도합니다.")
                    // 액세스 토큰이 만료된 경우 리프레시 토큰으로 갱신 시도
                    do {
                        let newTokens = try await authRepository.refreshToken()
                        TokenStorage.accessToken = newTokens.accessToken
                        TokenStorage.refreshToken = newTokens.refreshToken
                        
                        // 토큰 만료 시간 설정 (현재 시간 + 2분)
                        TokenStorage.accessTokenExpiration = Date().addingTimeInterval(120)
                        // 리프레시 토큰 만료 시간 설정 (현재 시간 + 5분)
                        TokenStorage.refreshTokenExpiration = Date().addingTimeInterval(300)
                        
                        print("✅ 토큰 갱신 성공")
                        TokenStorage.printTokenStatus()
                        newState.isLoggedIn = true
                    } catch {
                        print("❌ 토큰 갱신 실패:", error)
                        TokenStorage.clear()
                        newState.isLoggedIn = false
                        newState.errorMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
                    }
                } else {
                    print("✅ AccessToken이 유효합니다.")
                    newState.isLoggedIn = true
                }
            } else {
                print("❌ 저장된 토큰이 없습니다.")
                newState.isLoggedIn = false
            }
            
        case .loginSucceeded:
            print("\n✅ 로그인 성공")
            TokenStorage.printTokenStatus()
            newState.isLoggedIn = true
            
        case .loginFailed(let message):
            print("\n❌ 로그인 실패:", message)
            newState.errorMessage = message
            newState.isLoggedIn = false
        }
        
        return newState
    }
} 
