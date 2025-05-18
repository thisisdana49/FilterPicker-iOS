//
//  AuthView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var store: AuthStore
    
    init(appStore: AppStore) {
        _store = StateObject(wrappedValue: AuthStore(
            reducer: AuthReducer(appStore: appStore)
        ))
    }
    
    var body: some View {
        VStack(spacing: 16) {
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
        }
        .padding()
    }
}

#Preview {
    AuthView(appStore: AppStore(reducer: AppReducer()))
}
