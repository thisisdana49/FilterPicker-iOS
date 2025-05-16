//
//  TokenStorage.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

enum TokenStorage {
    private enum Key {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let accessTokenExpiration = "accessTokenExpiration"
        static let refreshTokenExpiration = "refreshTokenExpiration"
    }

    static var accessToken: String? {
        get { UserDefaults.standard.string(forKey: Key.accessToken) }
        set { UserDefaults.standard.set(newValue, forKey: Key.accessToken) }
    }

    static var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: Key.refreshToken) }
        set { UserDefaults.standard.set(newValue, forKey: Key.refreshToken) }
    }
    
    static var accessTokenExpiration: Date? {
        get { UserDefaults.standard.object(forKey: Key.accessTokenExpiration) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Key.accessTokenExpiration) }
    }
    
    static var refreshTokenExpiration: Date? {
        get { UserDefaults.standard.object(forKey: Key.refreshTokenExpiration) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Key.refreshTokenExpiration) }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
        UserDefaults.standard.removeObject(forKey: Key.refreshToken)
        UserDefaults.standard.removeObject(forKey: Key.accessTokenExpiration)
        UserDefaults.standard.removeObject(forKey: Key.refreshTokenExpiration)
        print("🔒 TokenStorage: 모든 토큰이 삭제되었습니다.")
    }
    
    static func isAccessTokenExpired() -> Bool {
        guard let expiration = accessTokenExpiration else { return true }
        let isExpired = Date() >= expiration
        print("🔑 AccessToken 상태:")
        print("   - 만료 시간: \(expiration)")
        print("   - 남은 시간: \(Int(expiration.timeIntervalSince(Date())))초")
        print("   - 만료 여부: \(isExpired ? "만료됨" : "유효함")")
        return isExpired
    }
    
    static func isRefreshTokenExpired() -> Bool {
        guard let expiration = refreshTokenExpiration else { return true }
        let isExpired = Date() >= expiration
        print("🔄 RefreshToken 상태:")
        print("   - 만료 시간: \(expiration)")
        print("   - 남은 시간: \(Int(expiration.timeIntervalSince(Date())))초")
        print("   - 만료 여부: \(isExpired ? "만료됨" : "유효함")")
        return isExpired
    }
    
    static func printTokenStatus() {
        print("\n🔐 현재 토큰 상태:")
        print("-------------------")
        if let accessToken = accessToken {
            print("✅ AccessToken: 존재함")
            isAccessTokenExpired()
        } else {
            print("❌ AccessToken: 없음")
        }
        
        if let refreshToken = refreshToken {
            print("✅ RefreshToken: 존재함")
            isRefreshTokenExpired()
        } else {
            print("❌ RefreshToken: 없음")
        }
        print("-------------------\n")
    }
}
