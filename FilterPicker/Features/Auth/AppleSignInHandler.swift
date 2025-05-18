import Foundation
import AuthenticationServices

final class AppleSignInHandler {
    static func handleSignInResult(_ result: Result<ASAuthorization, Error>, completion: @escaping (Result<(idToken: String, nick: String?), Error>) -> Void) {
        switch result {
        case .success(let authResults):
            print("✅ Apple 로그인 성공:", authResults)
            
            // Apple ID 토큰 추출
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                  let idToken = appleIDCredential.identityToken,
                  let tokenString = String(data: idToken, encoding: .utf8) else {
                completion(.failure(AuthError.invalidCredentials))
                return
            }
            
            // 닉네임 추출 (첫 로그인 시에만 제공됨)
            let nick = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            completion(.success((idToken: tokenString, nick: nick.isEmpty ? nil : nick)))
            
        case .failure(let error):
            print("❌ Apple 로그인 실패:", error)
            completion(.failure(error))
        }
    }
} 