//
//  FilterPickerApp.swift
//  FilterPicker
//
//  Created by 조다은 on 5/12/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct FilterPickerApp: App {
//    @StateObject private var store = AppStore()
    
    // Firebase 설정을 위한 app delegate 등록
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // 카카오 SDK 초기화
        KakaoSDK.initSDK(appKey: AppConfig.kakaoNativeAppKey)
        
        // 이미지 캐시 초기화 (싱글톤이므로 미리 초기화)
        _ = ImageCacheManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            AppRoute()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                    // 메모리 경고 시 캐시 정리
                    ImageCacheManager.shared.handleMemoryWarning()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // 백그라운드 진입 시 캐시 최적화
                    ImageCacheManager.shared.handleAppDidEnterBackground()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    // 앱 종료 시 리소스 정리
                    ImageCacheManager.shared.handleAppWillTerminate()
                }
        }
    }
}
