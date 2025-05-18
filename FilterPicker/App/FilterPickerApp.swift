//
//  FilterPickerApp.swift
//  FilterPicker
//
//  Created by 조다은 on 5/12/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct FilterPickerApp: App {
//    @StateObject private var store = AppStore()
    
    init() {
        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: AppConfig.kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            AppRoute()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
