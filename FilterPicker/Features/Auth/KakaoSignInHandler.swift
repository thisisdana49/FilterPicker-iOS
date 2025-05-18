import Foundation
import KakaoSDKUser

final class KakaoSignInHandler {
    static func handleSignIn(completion: @escaping (Result<String, Error>) -> Void) {
        // 카카오톡 설치 여부 확인
        if UserApi.isKakaoTalkLoginAvailable() {
            // 카카오톡으로 로그인
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("❌ 카카오톡 로그인 실패:", error)
                    completion(.failure(error))
                    return
                }
                
                guard let oauthToken = oauthToken?.accessToken else {
                    completion(.failure(AuthError.invalidCredentials))
                    return
                }
                
                print("✅ 카카오톡 로그인 성공")
                completion(.success(oauthToken))
            }
        } else {
            // 카카오 계정으로 로그인
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print("❌ 카카오 계정 로그인 실패:", error)
                    completion(.failure(error))
                    return
                }
                
                guard let oauthToken = oauthToken?.accessToken else {
                    completion(.failure(AuthError.invalidCredentials))
                    return
                }
                
                print("✅ 카카오 계정 로그인 성공")
                completion(.success(oauthToken))
            }
        }
    }
} 