//
//  AuthState.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

struct AuthState {
    var email: String = ""
    var password: String = ""
    var isLoggedIn: Bool = false
    var errorMessage: String? = nil
    var isLoading: Bool = false
}
