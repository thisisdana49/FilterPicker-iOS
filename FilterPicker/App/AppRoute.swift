//
//  AppRoute.swift
//  FilterPicker
//
//  Created by 조다은 on 5/16/25.
//

import SwiftUI

struct AppRoute: View {
    @StateObject private var store = AppStore(reducer: AppReducer())
    
    var body: some View {
        Group {
            if store.state.isLoggedIn {
                Text("감성적인 필터")
                    .fontStyle(.mulgyeolTitle1)

                Text("로그인을 진행해주세요")
                    .fontStyle(.body1)

                Text("₩1,500")
                    .fontStyle(.caption1)
            } else {
                AuthView(appStore: store)
            }
        }
        .onAppear {
            store.send(.checkAutoLogin)
        }
    }
}

#Preview {
    AppRoute()
} 
