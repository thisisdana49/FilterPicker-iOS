//
//  FilterAPIService.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation
import Combine

protocol FilterAPIService {
  func fetchFilters(_ request: FilterListRequest) async throws -> FilterListResponse
  func toggleLike(filterId: String, likeStatus: Bool) async throws -> LikeResponse
}

final class DefaultFilterAPIService: FilterAPIService {
  private let apiService: APIService
  
  init(apiService: APIService = DefaultAPIService()) {
    self.apiService = apiService
  }
  
  func fetchFilters(_ request: FilterListRequest) async throws -> FilterListResponse {
    let apiRequest = APIRequest(
      path: "/v1/filters",
      method: .get,
      queryParameters: request.queryParameters
    )
    
    return try await apiService.request(apiRequest)
  }
  
  func toggleLike(filterId: String, likeStatus: Bool) async throws -> LikeResponse {
    let apiRequest = APIRequest(
      path: "/v1/filters/\(filterId)/like",
      method: .post,
      body: ["like_status": likeStatus]
    )
    
    return try await apiService.request(apiRequest)
  }
}

// MARK: - Helper Extensions

private extension FilterListRequest {
  var queryParameters: [String: String] {
    var params: [String: String] = [
      "limit": "\(limit)",
      "order_by": orderBy
    ]
    
    if let next = next, !next.isEmpty {
      params["next"] = next
    }
    
    if let category = category, !category.isEmpty {
      params["category"] = category
    }
    
    return params
  }
}
