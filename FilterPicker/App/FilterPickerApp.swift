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
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    // 자동 초기화 방지 설정에 따른 수동 활성화
    Messaging.messaging().isAutoInitEnabled = true
    
    // 알림 센터 델리게이트 설정
    UNUserNotificationCenter.current().delegate = self
    
    // Firebase Messaging 델리게이트 설정
    Messaging.messaging().delegate = self
    
    // 알림 권한 요청
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { granted, error in
        print("Notification permission granted: \(granted)")
        if let error = error {
          print("Notification permission error: \(error)")
        }
        
        DispatchQueue.main.async {
          print("Registering for remote notifications...")
          application.registerForRemoteNotifications()
        }
      }
    )
    
    return true
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ APNs registration successful!")
    
    // APNs 디바이스 토큰을 문자열로 변환하여 출력
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("APNs Device Token: \(token)")
    
    // Firebase에 APNs 토큰 설정
    Messaging.messaging().apnsToken = deviceToken
    print("APNs token set to Firebase Messaging")
    
    // APNs 토큰 설정 후 FCM 토큰 가져오기
    Messaging.messaging().token { token, error in
      if let error = error {
        print("Error fetching FCM registration token: \(error)")
      } else if let token = token {
        print("FCM registration token: \(token)")
        // 서버에 토큰 전송 로직 추가 가능
      }
    }
  }
  
  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error)")
    print("Error details: \(error.localizedDescription)")
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  // 포그라운드에서 알림을 받을 경우 처리
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    
    // 알림을 표시하도록 설정
    completionHandler([[.alert, .sound]])
  }
  
  // 알림을 탭했을 때 처리
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    // 알림 탭 처리 로직 추가 가능
    
    completionHandler()
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")

    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
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
