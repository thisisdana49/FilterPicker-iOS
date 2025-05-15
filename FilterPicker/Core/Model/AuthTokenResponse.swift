//
//  AuthTokenResponse.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

struct AuthTokenResponse: Decodable {
    let userId: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nick
        case accessToken
        case refreshToken
    }
}
