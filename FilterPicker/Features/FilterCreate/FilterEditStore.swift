//
//  FilterEditStore.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI
import Combine

class FilterEditStore: ObservableObject {
    @Published var state = FilterEditState()
    
    private let reducer = FilterEditReducer()
    
    init(image: UIImage? = nil) {
        if let image = image {
            self.state.originalImage = image
            self.state.editedImage = image
        }
    }
    
    func send(_ intent: FilterEditIntent) {
        reducer.reduce(state: &state, intent: intent)
    }
} 