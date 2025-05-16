//
//  AppStore.swift
//  FilterPicker
//
//  Created by 조다은 on 5/16/25.
//

import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var state = AppState()
    private let reducer: AppReducer
    
    init(reducer: AppReducer) {
        self.reducer = reducer
    }
    
    func send(_ intent: AppIntent) {
        Task {
            let newState = await reducer.reduce(state: state, intent: intent)
            self.state = newState
        }
    }
} 
