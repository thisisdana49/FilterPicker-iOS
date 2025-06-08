//
//  ToggleLikeUseCase.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

protocol ToggleLikeUseCase {
  func execute(filterId: String, currentlyLiked: Bool) async throws -> Bool
}

final class DefaultToggleLikeUseCase: ToggleLikeUseCase {
  private let repository: FilterRepositoryProtocol
  
  init(repository: FilterRepositoryProtocol = FilterRepository()) {
    self.repository = repository
  }
  
  func execute(filterId: String, currentlyLiked: Bool) async throws -> Bool {
    // 현재 상태의 반대로 토글
    let newLikeStatus = !currentlyLiked
    let response = try await repository.toggleLike(filterId: filterId, likeStatus: newLikeStatus)
    return response.likeStatus
  }
} 