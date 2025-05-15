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
    }

    static var accessToken: String? {
        get { UserDefaults.standard.string(forKey: Key.accessToken) }
        set { UserDefaults.standard.set(newValue, forKey: Key.accessToken) }
    }

    static var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: Key.refreshToken) }
        set { UserDefaults.standard.set(newValue, forKey: Key.refreshToken) }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
        UserDefaults.standard.removeObject(forKey: Key.refreshToken)
    }
}
