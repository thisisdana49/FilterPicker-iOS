//
//  AuthIntent.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

enum AuthIntent {
    case emailChanged(String)
    case passwordChanged(String)
    case loginTapped
    case loginSucceeded(AuthTokenResponse)
    case loginFailed(String)
    case appleLoginTapped
    case appleLoginSucceeded(idToken: String, nick: String?)
    case appleLoginFailed(String)
    case kakaoLoginTapped
    case kakaoLoginSucceeded(accessToken: String, nick: String?)
    case kakaoLoginFailed(String)
}
