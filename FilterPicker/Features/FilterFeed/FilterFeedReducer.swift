//
//  FilterFeedReducer.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

final class FilterFeedReducer: ObservableObject {
  @Published var state = FilterFeedState()
  
  private let fetchFiltersUseCase: FetchFiltersUseCase
  private let toggleLikeUseCase: ToggleLikeUseCase
  
  init(
    fetchFiltersUseCase: FetchFiltersUseCase = DefaultFetchFiltersUseCase(),
    toggleLikeUseCase: ToggleLikeUseCase = DefaultToggleLikeUseCase()
  ) {
    self.fetchFiltersUseCase = fetchFiltersUseCase
    self.toggleLikeUseCase = toggleLikeUseCase
    
    // 초기 데이터 로드 제거 - View의 onAppear에서 명시적으로 호출하도록 변경
    // Task {
    //   await handleIntent(.loadTopRanking)
    //   await handleIntent(.loadFilters)
    // }
  }
  
  @MainActor
  func handleIntent(_ intent: FilterFeedIntent) async {
    switch intent {
    case .loadTopRanking:
      await loadTopRanking()
      
    case .changeRankingType(let type):
      state.selectedRankingType = type
      await loadTopRankingIfNeeded(for: type)
      
    case .loadFilters:
      await loadFilters(refresh: false)
      
    case .loadMoreFilters:
      await loadMoreFilters()
      
    case .refreshFilters:
      await loadFilters(refresh: true)
      
    case .toggleLike(let filterId):
      await toggleLike(filterId: filterId)
      
    case .filterTapped(let filterId):
      print("Filter tapped: \(filterId)")
      // 향후 필터 상세 화면 이동 구현
      
    case .clearError:
      state.topRankingError = nil
      state.filtersError = nil
    }
  }
  
  // MARK: - Private Methods
  
  private func loadTopRanking() async {
    state.isLoadingTopRanking = true
    state.topRankingError = nil
    
    // Mock 데이터로 임시 구현 (향후 실제 API로 교체)
    do {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기
      
      state.topRankingFilters = [
        .popularity: MockData.topRankingFilters,
        .purchase: MockData.topRankingFilters.shuffled(),
        .latest: MockData.topRankingFilters.reversed()
      ]
    } catch {
      state.topRankingError = "Top Ranking을 불러올 수 없습니다."
    }
    
    state.isLoadingTopRanking = false
  }
  
  private func loadTopRankingIfNeeded(for type: FilterRankingType) async {
    if state.topRankingFilters[type]?.isEmpty ?? true {
      await loadTopRanking()
    }
  }
  
  private func loadFilters(refresh: Bool) async {
    print("\n🔍 [FilterFeed] loadFilters 시작 - refresh: \(refresh)")
    
    // 토큰 상태 체크
    TokenStorage.printTokenStatus()
    
    // 새로고침이 아닌데 재시도 횟수 초과 시 중단
    if !refresh && !state.shouldAllowRetry {
      print("❌ [FilterFeed] 최대 재시도 횟수 초과 - 요청 중단")
      return
    }
    
    if refresh {
      state.isRefreshing = true
      state.nextCursor = nil
      state.hasMoreFilters = true
      // 새로고침 시 재시도 상태 초기화
      state.resetRetryState()
    } else {
      state.isLoadingFilters = true
    }
    
    state.filtersError = nil
    
    do {
      let request = FilterListRequest(
        next: refresh ? nil : state.nextCursor,
        limit: 10,
        category: nil,
        orderBy: .latest
      )
      
      print("🌐 [FilterFeed] API 호출 시작: FetchFiltersUseCase (재시도: \(state.retryCount))")
      let response = try await fetchFiltersUseCase.execute(request)
      print("✅ [FilterFeed] API 호출 성공")
      
      if refresh {
        state.filters = response.data
        // 기존 좋아요 상태 유지
        state.likedFilterIds = Set(response.data.filter { $0.isLiked }.map { $0.id })
      } else {
        state.filters = response.data
        state.likedFilterIds = Set(response.data.filter { $0.isLiked }.map { $0.id })
      }
      
      state.nextCursor = response.nextCursor
      state.hasMoreFilters = response.hasNext
      
      // 성공 시 재시도 상태 초기화
      state.resetRetryState()
      
    } catch {
      print("❌ [FilterFeed] Error loading filters: \(error)")
      
      // 재시도 횟수 증가
      state.incrementRetryCount()
      
      // 적절한 오류 메시지 설정
      if state.hasReachedMaxRetry {
        state.filtersError = "필터 목록을 불러올 수 없습니다.\n잠시 후 다시 시도해주세요."
        state.lastErrorMessage = "최대 재시도 횟수(\(state.maxRetryCount)회)에 도달했습니다."
        state.hasMoreFilters = false // 더 이상 로드하지 않도록 설정
      } else {
        state.filtersError = "필터 목록을 불러오는 중 오류가 발생했습니다. (재시도: \(state.retryCount)/\(state.maxRetryCount))"
      }
    }
    
    state.isLoadingFilters = false
    state.isRefreshing = false
  }
  
  private func loadMoreFilters() async {
    guard !state.isLoadingMore && state.hasMoreFilters && state.shouldAllowRetry else { 
      if !state.shouldAllowRetry {
        print("❌ [FilterFeed] loadMoreFilters - 최대 재시도 횟수 초과로 중단")
      }
      return 
    }
    
    state.isLoadingMore = true
    
    do {
      let request = FilterListRequest(
        next: state.nextCursor,
        limit: 10,
        category: nil,
        orderBy: .latest
      )
      
      print("🌐 [FilterFeed] 추가 로딩 API 호출 시작 (재시도: \(state.retryCount))")
      let response = try await fetchFiltersUseCase.execute(request)
      
      state.filters.append(contentsOf: response.data)
      state.nextCursor = response.nextCursor
      state.hasMoreFilters = response.hasNext
      
      // 새로 추가된 필터의 좋아요 상태 업데이트
      let newLikedIds = Set(response.data.filter { $0.isLiked }.map { $0.id })
      state.likedFilterIds.formUnion(newLikedIds)
      
      // 성공 시 재시도 상태 초기화
      state.resetRetryState()
      
    } catch {
      print("❌ [FilterFeed] Error loading more filters: \(error)")
      
      // 재시도 횟수 증가
      state.incrementRetryCount()
      
      // 적절한 오류 메시지 설정
      if state.hasReachedMaxRetry {
        state.filtersError = "추가 필터를 불러올 수 없습니다.\n잠시 후 새로고침해주세요."
        state.lastErrorMessage = "최대 재시도 횟수(\(state.maxRetryCount)회)에 도달했습니다."
        state.hasMoreFilters = false // 더 이상 로드하지 않도록 설정
      } else {
        state.filtersError = "추가 필터 로딩 중 오류가 발생했습니다. (재시도: \(state.retryCount)/\(state.maxRetryCount))"
      }
    }
    
    state.isLoadingMore = false
  }
  
  private func toggleLike(filterId: String) async {
    let currentlyLiked = state.likedFilterIds.contains(filterId)
    
    // 옵티미스틱 업데이트
    if currentlyLiked {
      state.likedFilterIds.remove(filterId)
    } else {
      state.likedFilterIds.insert(filterId)
    }
    
    do {
      try await toggleLikeUseCase.execute(filterId: filterId, isLiked: currentlyLiked)
    } catch {
      // 실패 시 롤백
      if currentlyLiked {
        state.likedFilterIds.insert(filterId)
      } else {
        state.likedFilterIds.remove(filterId)
      }
      print("❌ Error toggling like: \(error)")
    }
  }
} 
