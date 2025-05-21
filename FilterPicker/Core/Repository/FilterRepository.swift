//
//  FilterRepositoryProtocol.swift
//  FilterPicker
//
//  Created by 조다은 on 5/21/25.
//


import Foundation

protocol FilterRepositoryProtocol {
    func fetchTodayFilter() async throws -> TodayFilterResponse
}

final class FilterRepository: FilterRepositoryProtocol {
    private let apiService: APIService
    
    init(apiService: APIService = DefaultAPIService()) {
        self.apiService = apiService
    }
    
    func fetchTodayFilter() async throws -> TodayFilterResponse {
        let request = APIRequest(
            path: "/v1/filters/today-filter",
            method: .get
        )
        
        return try await apiService.request(request)
    }
} 
