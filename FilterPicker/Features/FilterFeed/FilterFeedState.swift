//
//  FilterFeedState.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

struct FilterFeedState: Equatable {
  // MARK: - Top Ranking
  var selectedRankingType: FilterRankingType = .popularity
  var topRankingFilters: [FilterRankingType: [Filter]] = [:]
  var isLoadingTopRanking = false
  var topRankingError: String?
  
  // MARK: - Filter Feed
  var filters: [Filter] = []
  var isLoadingFilters = false
  var isLoadingMore = false
  var filtersError: String?
  var nextCursor: String?
  var hasMoreFilters = true
  
  // MARK: - Initial Load State
  var hasInitiallyLoadedTopRanking = false
  var hasInitiallyLoadedFilters = false
  
  // MARK: - Retry Logic
  var retryCount: Int = 0
  var maxRetryCount: Int = 3
  var hasReachedMaxRetry: Bool = false
  var lastErrorMessage: String?
  
  // MARK: - Filter State
  var likedFilterIds: Set<String> = []
  
  // MARK: - UI State
  var isRefreshing = false
  
  // MARK: - User State Preservation
  var lastViewedFilterIndex: Int = 0
  var shouldRestoreScrollPosition = false
  var viewReturnedFromDetail = false
  
  // MARK: - Computed Properties
  var currentTopRankingFilters: [Filter] {
    return topRankingFilters[selectedRankingType] ?? []
  }
  
  var updatedFilters: [Filter] {
    return filters.map { filter in
      Filter(
        id: filter.id,
        category: filter.category,
        title: filter.title,
        description: filter.description,
        files: filter.files,
        creator: filter.creator,
        isLiked: likedFilterIds.contains(filter.id),
        likeCount: filter.likeCount,
        buyerCount: filter.buyerCount,
        createdAt: filter.createdAt,
        updatedAt: filter.updatedAt
      )
    }
  }
  
  var isLoading: Bool {
    return isLoadingTopRanking || isLoadingFilters || isRefreshing
  }
  
  var hasError: Bool {
    return topRankingError != nil || filtersError != nil || hasReachedMaxRetry
  }
  
  var shouldAllowRetry: Bool {
    return retryCount < maxRetryCount && !hasReachedMaxRetry
  }
  
  // MARK: - Skeleton State Computed Properties
  var shouldShowTopRankingSkeleton: Bool {
    // 로딩 중이고 아직 데이터가 없을 때만 스켈레톤 표시
    return isLoadingTopRanking && topRankingFilters.isEmpty
  }
  
  var shouldShowFiltersSkeleton: Bool {
    // 로딩 중이고 아직 데이터가 없을 때만 스켈레톤 표시
    return isLoadingFilters && filters.isEmpty
  }
  
  // MARK: - Retry Reset Methods
  mutating func resetRetryState() {
    retryCount = 0
    hasReachedMaxRetry = false
    lastErrorMessage = nil
  }
  
  mutating func resetInitialLoadState() {
    hasInitiallyLoadedTopRanking = false
    hasInitiallyLoadedFilters = false
  }
  
  mutating func incrementRetryCount() {
    retryCount += 1
    if retryCount >= maxRetryCount {
      hasReachedMaxRetry = true
    }
  }
} 