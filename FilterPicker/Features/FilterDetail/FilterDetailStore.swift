//
//  FilterDetailStore.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation
import Combine

final class FilterDetailStore: ObservableObject {
    @Published var state = FilterDetailState()
    
    private let reducer: FilterDetailReducer
    
    init(reducer: FilterDetailReducer = FilterDetailReducer()) {
        self.reducer = reducer
    }
    
    func dispatch(_ intent: FilterDetailIntent) {
        Task { @MainActor in
            self.state = await reducer.reduce(state: state, intent: intent)
        }
    }
} 