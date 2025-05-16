//
//  AppReducer.swift
//  FilterPicker
//
//  Created by 조다은 on 5/16/25.
//

import Foundation

struct AppReducer {
    func reduce(state: AppState, intent: AppIntent) async -> AppState {
        var newState = state
        
        switch intent {
        case .checkAutoLogin:
            newState.isLoggedIn = TokenStorage.accessToken != nil
            
        case .loginSucceeded:
            newState.isLoggedIn = true
            
        case .loginFailed(let message):
            newState.errorMessage = message
            newState.isLoggedIn = false
        }
        
        return newState
    }
} 
