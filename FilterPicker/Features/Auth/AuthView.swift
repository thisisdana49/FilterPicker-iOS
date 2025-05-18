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
                        AppleSignInHandler.handleSignInResult(result) { signInResult in
                            switch signInResult {
                            case .success(let (idToken, nick)):
                                store.send(.appleLoginSucceeded(idToken: idToken, nick: nick))
                            case .failure(let error):
                                store.send(.appleLoginFailed(error.localizedDescription))
                            }
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
