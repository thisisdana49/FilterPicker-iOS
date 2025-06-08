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
      // 새로고침 시 초기 로드 상태 리셋
      state.resetInitialLoadState()
      await loadFilters(refresh: true)
      
    case .toggleLike(let filterId):
      await toggleLike(filterId: filterId)
      
    case .filterTapped(let filterId):
      print("Filter tapped: \(filterId)")
      // 향후 필터 상세 화면 이동 구현
      
    case .saveScrollPosition(let index):
      state.lastViewedFilterIndex = index
      print("📍 [State] 스크롤 위치 저장: \(index)")
      
    case .markReturnedFromDetail:
      state.viewReturnedFromDetail = true
      state.shouldRestoreScrollPosition = true
      print("🔄 [State] 상세화면에서 돌아옴 - 스크롤 위치 복원 예정")
      
    case .resetViewState:
      state.viewReturnedFromDetail = false
      state.shouldRestoreScrollPosition = false
      print("🔄 [State] 뷰 상태 리셋")
      
    case .clearError:
      state.topRankingError = nil
      state.filtersError = nil
    }
  }
  
  // MARK: - Private Methods
  
  private func loadTopRanking() async {
    // 이미 로드했고 데이터가 있으면 스킵
    if state.hasInitiallyLoadedTopRanking && !state.topRankingFilters.isEmpty {
      print("🔄 [FilterFeed] Top Ranking 이미 로드됨 - API 호출 스킵")
      return
    }
    
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
      
      // 초기 로드 완료 표시
      state.hasInitiallyLoadedTopRanking = true
      
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
    print("    현재 상태: hasInitiallyLoadedFilters=\(state.hasInitiallyLoadedFilters), filters.count=\(state.filters.count)")
    
    // 새로고침이 아닌데 이미 로드했고 데이터가 있으면 스킵
    if !refresh && state.hasInitiallyLoadedFilters && !state.filters.isEmpty {
      print("🔄 [FilterFeed] Filters 이미 로드됨 - API 호출 스킵")
      return
    }
    
    print("📞 [FilterFeed] API 호출 진행 - 조건 통과")
    
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
      
      // 초기 로드 완료 표시
      state.hasInitiallyLoadedFilters = true
      
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
    guard !state.isLoadingMore && state.hasMoreFilters else { 
      print("🔄 [FilterFeed] loadMoreFilters - 가드 조건: isLoadingMore=\(state.isLoadingMore), hasMoreFilters=\(state.hasMoreFilters)")
      return 
    }
    
    print("🚀 [FilterFeed] loadMoreFilters 시작 - nextCursor: \(state.nextCursor ?? "nil")")
    state.isLoadingMore = true
    
    do {
      let request = FilterListRequest(
        next: state.nextCursor,
        limit: 10,
        category: nil,
        orderBy: .latest
      )
      
      print("🌐 [FilterFeed] 추가 로딩 API 호출 시작")
      let response = try await fetchFiltersUseCase.execute(request)
      print("✅ [FilterFeed] 추가 로딩 성공 - \(response.data.count)개 필터 추가됨")
      
      state.filters.append(contentsOf: response.data)
      state.nextCursor = response.nextCursor
      state.hasMoreFilters = response.hasNext
      
      print("📊 [FilterFeed] 현재 총 \(state.filters.count)개 필터, hasMore: \(state.hasMoreFilters)")
      
      // 새로 추가된 필터의 좋아요 상태 업데이트
      let newLikedIds = Set(response.data.filter { $0.isLiked }.map { $0.id })
      state.likedFilterIds.formUnion(newLikedIds)
      
    } catch {
      print("❌ [FilterFeed] Error loading more filters: \(error)")
      // 페이지네이션 실패 시에만 에러 표시, hasMoreFilters는 그대로 유지
      state.filtersError = "추가 필터를 불러오는 중 오류가 발생했습니다."
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
      let newLikeStatus = try await toggleLikeUseCase.execute(filterId: filterId, currentlyLiked: currentlyLiked)
      
      // 서버 응답에 따라 최종 상태 동기화
      if newLikeStatus {
        state.likedFilterIds.insert(filterId)
      } else {
        state.likedFilterIds.remove(filterId)
      }
      
      print("✅ Filter like status updated: \(filterId) -> \(newLikeStatus)")
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
