//
//  FilterDetailAPIService.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

protocol FilterDetailAPIService {
    func getFilterDetail(filterId: String) async throws -> FilterDetailResponse
    func toggleLike(filterId: String) async throws -> EmptyResponse
}

final class DefaultFilterDetailAPIService: FilterDetailAPIService {
    private let apiService: APIService
    
    init(apiService: APIService = DefaultAPIService()) {
        self.apiService = apiService
    }
    
    func getFilterDetail(filterId: String) async throws -> FilterDetailResponse {
        let request = APIRequest(
            path: "/v1/filters/\(filterId)",
            method: .get
        )
        
        return try await apiService.request(request)
    }
    
    func toggleLike(filterId: String) async throws -> EmptyResponse {
        let request = APIRequest(
            path: "/v1/filters/\(filterId)/like",
            method: .post
        )
        
        return try await apiService.request(request)
    }
}

