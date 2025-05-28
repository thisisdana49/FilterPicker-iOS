//
//  FetchFiltersUseCase.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation
import Combine

protocol FetchFiltersUseCase {
  func execute(_ request: FilterListRequest) async throws -> FilterListResponse
}

final class DefaultFetchFiltersUseCase: FetchFiltersUseCase {
  private let repository: FilterRepositoryProtocol
  
  init(repository: FilterRepositoryProtocol = FilterRepository()) {
    self.repository = repository
  }
  
  func execute(_ request: FilterListRequest) async throws -> FilterListResponse {
    return try await repository.fetchFilters(request)
  }
} 