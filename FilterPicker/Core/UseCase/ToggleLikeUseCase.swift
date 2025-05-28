//
//  ToggleLikeUseCase.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

protocol ToggleLikeUseCase {
  func execute(filterId: String, isLiked: Bool) async throws -> Void
}

final class DefaultToggleLikeUseCase: ToggleLikeUseCase {
  private let repository: FilterRepositoryProtocol
  
  init(repository: FilterRepositoryProtocol = FilterRepository()) {
    self.repository = repository
  }
  
  func execute(filterId: String, isLiked: Bool) async throws -> Void {
    if isLiked {
      try await repository.unlikeFilter(filterId: filterId)
    } else {
      try await repository.likeFilter(filterId: filterId)
    }
  }
} 