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
  
  // MARK: - Singleton Pattern
  static let shared = FilterFeedStore()
  
  private init(reducer: FilterFeedReducer = FilterFeedReducer()) {
    self.reducer = reducer
    
    // Reducer의 상태 변경을 Store에 동기화
    reducer.$state
      .assign(to: \.state, on: self)
      .store(in: &cancellables)
    
    print("📦 [FilterFeedStore] 싱글톤 Store 초기화됨")
  }
  
  func send(_ intent: FilterFeedIntent) {
    Task {
      await reducer.handleIntent(intent)
    }
  }
} 