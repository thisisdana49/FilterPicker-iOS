//
//  FilterCreateStore.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI
import Combine

class FilterCreateStore: ObservableObject {
    @Published var state = FilterCreateState()
    
    private let reducer = FilterCreateReducer()
    
    func send(_ intent: FilterCreateIntent) {
        reducer.reduce(state: &state, intent: intent)
    }
} 