//
//  AuthStore.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var state = AuthState()
    private let reducer: AuthReducer

    init(reducer: AuthReducer) {
        self.reducer = reducer
    }

    func send(_ intent: AuthIntent) {
        Task {
            let newState = await reducer.reduce(state: state, intent: intent)
            self.state = newState
        }
    }
}
