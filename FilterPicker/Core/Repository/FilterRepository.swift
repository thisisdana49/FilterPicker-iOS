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
    
    // 새로운 필터 목록 API
    func fetchFilters(_ request: FilterListRequest) async throws -> FilterListResponse
    func toggleLike(filterId: String, likeStatus: Bool) async throws -> LikeResponse
}

final class FilterRepository: FilterRepositoryProtocol {
    private let apiService: APIService
    private let filterAPIService: FilterAPIService
    
    init(
        apiService: APIService = DefaultAPIService(),
        filterAPIService: FilterAPIService = DefaultFilterAPIService()
    ) {
        self.apiService = apiService
        self.filterAPIService = filterAPIService
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
    
    // MARK: - 새로운 필터 목록 API 구현
    
    func fetchFilters(_ request: FilterListRequest) async throws -> FilterListResponse {
        print("🌐 [Request] GET /v1/filters - \(request)")
        do {
            let response = try await filterAPIService.fetchFilters(request)
            print("📦 [Response] Filters count: \(response.data.count), next_cursor: \(response.nextCursor)")
            return response
        } catch {
            print("❌ [Error] FetchFilters: \(error)")
            throw error
        }
    }
    
    func toggleLike(filterId: String, likeStatus: Bool) async throws -> LikeResponse {
        print("🌐 [Request] POST /v1/filters/\(filterId)/like - likeStatus: \(likeStatus)")
        do {
            let response = try await filterAPIService.toggleLike(filterId: filterId, likeStatus: likeStatus)
            print("✅ [Success] Filter like toggled: \(filterId), result: \(response.likeStatus)")
            return response
        } catch {
            print("❌ [Error] ToggleLike: \(error)")
            throw error
        }
    }
} 
