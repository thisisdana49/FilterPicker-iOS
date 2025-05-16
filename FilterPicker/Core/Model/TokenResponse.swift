//
//  TokenResponse.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
} 
