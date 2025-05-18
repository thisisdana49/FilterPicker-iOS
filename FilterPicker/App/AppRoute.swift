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
                Text("메인 화면") // TODO: MainView로 교체
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
