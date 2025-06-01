//
//  FilterDetailRepository.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

protocol FilterDetailRepository {
    func getFilterDetail(filterId: String) async throws -> FilterDetailResponse
    func toggleLike(filterId: String) async throws
}

final class DefaultFilterDetailRepository: FilterDetailRepository {
    private let apiService: FilterDetailAPIService
    
    init(apiService: FilterDetailAPIService = DefaultFilterDetailAPIService()) {
        self.apiService = apiService
    }
    
    func getFilterDetail(filterId: String) async throws -> FilterDetailResponse {
        return try await apiService.getFilterDetail(filterId: filterId)
    }
    
    func toggleLike(filterId: String) async throws {
        _ = try await apiService.toggleLike(filterId: filterId)
    }
} 