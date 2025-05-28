//
//  FilterFeedStore.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation
import Combine

final class FilterFeedStore: ObservableObject {
  @Published var state = FilterFeedState()
  
  private let reducer: FilterFeedReducer
  private var cancellables = Set<AnyCancellable>()
  
  init(reducer: FilterFeedReducer = FilterFeedReducer()) {
    self.reducer = reducer
    
    // Reducer의 상태 변경을 Store에 동기화
    reducer.$state
      .assign(to: \.state, on: self)
      .store(in: &cancellables)
  }
  
  func send(_ intent: FilterFeedIntent) {
    Task {
      await reducer.handleIntent(intent)
    }
  }
} 