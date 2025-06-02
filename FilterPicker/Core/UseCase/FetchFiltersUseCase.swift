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
    print("📋 [UseCase] FetchFiltersUseCase.execute 시작")
    print("    Request: next=\(request.next ?? "nil"), limit=\(request.limit)")
    
    do {
      let response = try await repository.fetchFilters(request)
      print("✅ [UseCase] FetchFiltersUseCase.execute 성공 - \(response.data.count)개 필터 로드")
      return response
    } catch {
      print("❌ [UseCase] FetchFiltersUseCase.execute 실패: \(error)")
      throw error
    }
  }
} 