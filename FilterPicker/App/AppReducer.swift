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
            
            // 1. RefreshToken 존재 여부 확인
            guard let refreshToken = TokenStorage.refreshToken else {
                print("❌ 저장된 RefreshToken이 없습니다.")
                newState.isLoggedIn = false
                return newState
            }
            
            // 2. RefreshToken 만료 여부 확인
            if TokenStorage.isRefreshTokenExpired() {
                print("❌ RefreshToken이 만료되었습니다.")
                TokenStorage.clear()
                newState.isLoggedIn = false
                return newState
            }
            
            // 3. RefreshToken이 유효하면 로그인 상태로 설정
            // AccessToken 갱신은 첫 번째 API 요청 시 자동으로 처리됨
            print("✅ 유효한 RefreshToken 존재 - 자동 로그인 가능")
            if TokenStorage.isAccessTokenExpired() {
                print("ℹ️ AccessToken 만료됨 - 첫 API 요청 시 자동 갱신 예정")
            } else {
                print("✅ AccessToken도 유효함")
            }
            newState.isLoggedIn = true
            
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
