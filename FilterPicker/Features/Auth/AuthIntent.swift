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
    case loginSucceeded
    case loginFailed(String)
    case appleLoginTapped  // Apple 로그인 버튼 탭
}
