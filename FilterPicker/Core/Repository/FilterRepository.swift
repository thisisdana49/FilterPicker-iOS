//
//  FilterRepositoryProtocol.swift
//  FilterPicker
//
//  Created by 조다은 on 5/21/25.
//

import Foundation

protocol FilterRepositoryProtocol {
    func fetchTodayFilter() async throws -> TodayFilterResponse
    func fetchHotTrendFilters() async throws -> [HotTrendFilter]
    func fetchTodayAuthor() async throws -> TodayAuthorResponse
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
    
    func fetchHotTrendFilters() async throws -> [HotTrendFilter] {
        let request = APIRequest(
            path: "/v1/filters/hot-trend",
            method: .get
        )
        let response: HotTrendResponse = try await apiService.request(request)
        return response.data
    }
    
    func fetchTodayAuthor() async throws -> TodayAuthorResponse {
        let request = APIRequest(
            path: "/v1/users/today-author",
            method: .get
        )
        print("🌐 [Request] GET /v1/users/today-author")
        do {
            let response: TodayAuthorResponse = try await apiService.request(request)
            print("📦 [Response] TodayAuthor: \(response)")
            return response
        } catch {
            print("❌ [Error] TodayAuthor: \(error)")
            throw error
        }
    }
} 
