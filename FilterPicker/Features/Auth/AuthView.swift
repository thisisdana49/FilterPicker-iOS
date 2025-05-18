//
//  AuthView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @StateObject private var store: AuthStore
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(appStore: AppStore) {
        _store = StateObject(wrappedValue: AuthStore(
            reducer: AuthReducer(appStore: appStore)
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("이메일", text: Binding(
                get: { store.state.email },
                set: { store.send(.emailChanged($0)) }
            ))
            
            SecureField("비밀번호", text: Binding(
                get: { store.state.password },
                set: { store.send(.passwordChanged($0)) }
            ))
            
            if store.state.isLoading {
                ProgressView()
            } else {
                Button("로그인") {
                    store.send(.loginTapped)
                }
            }
            
            if let error = store.state.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            if store.state.isLoggedIn {
                Text("✅ 로그인 완료!")
            }
            
            // 소셜 로그인 섹션
            VStack(spacing: 16) {
                Text("또는")
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                
                // Apple 로그인 버튼
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            print("✅ Apple 로그인 성공:", authResults)
                            
                            // Apple ID 토큰 추출
                            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                                  let idToken = appleIDCredential.identityToken,
                                  let tokenString = String(data: idToken, encoding: .utf8) else {
                                store.send(.appleLoginFailed("Apple 로그인 정보를 가져오는데 실패했습니다."))
                                return
                            }
                            
                            // 닉네임 추출 (첫 로그인 시에만 제공됨)
                            let nick = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                                .compactMap { $0 }
                                .joined(separator: " ")
                            
                            store.send(.appleLoginSucceeded(idToken: tokenString, nick: nick.isEmpty ? nil : nick))
                            
                        case .failure(let error):
                            print("❌ Apple 로그인 실패:", error)
                            store.send(.appleLoginFailed(error.localizedDescription))
                        }
                    }
                )
                .frame(height: 50)
                .padding(.horizontal)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("오류"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인")) {
                    showAlert = false
                    alertMessage = ""
                }
            )
        }
        .onChange(of: store.state.errorMessage) { errorMessage in
            if let message = errorMessage, !message.isEmpty {
                alertMessage = message
                showAlert = true
            }
        }
    }
}

//#Preview {
//    AuthView()
//}
