import Foundation

@MainActor
final class MainStore: ObservableObject {
    @Published private(set) var state: MainState
    private let filterRepository: FilterRepositoryProtocol
    private let toggleLikeUseCase: ToggleLikeUseCase
    
    init(
        initialState: MainState = .initial,
        filterRepository: FilterRepositoryProtocol = FilterRepository(),
        toggleLikeUseCase: ToggleLikeUseCase = DefaultToggleLikeUseCase()
    ) {
        self.state = initialState
        self.filterRepository = filterRepository
        self.toggleLikeUseCase = toggleLikeUseCase
    }
    
    func dispatch(_ intent: MainIntent) {
        switch intent {
        case .fetchTodayFilter:
            // 이미 로드되었으면 재요청하지 않음
            guard !state.hasLoadedTodayFilter else { return }
            
            Task {
                do {
                    state.isLoading = true
                    state.error = nil
                    let todayFilter = try await filterRepository.fetchTodayFilter()
                    state.todayFilter = todayFilter
                    state.hasLoadedTodayFilter = true
                    state.isLoading = false
                } catch {
                    state.error = error
                    state.isLoading = false
                }
            }
            
        case .fetchHotTrendFilters:
            // 이미 로드되었으면 재요청하지 않음
            guard !state.hasLoadedHotTrendFilters else { return }
            
            Task {
                do {
                    state.isLoading = true
                    state.error = nil
                    let filters = try await filterRepository.fetchHotTrendFilters()
                    state.hotTrendFilters = filters
                    state.hasLoadedHotTrendFilters = true
                    state.isLoading = false
                } catch {
                    state.error = error
                    state.isLoading = false
                }
            }
            
        case .setTodayFilter(let filter):
            state.todayFilter = filter
            
        case .setHotTrendFilters(let filters):
            state.hotTrendFilters = filters
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setError(let error):
            state.error = error
            
        case .fetchTodayAuthor:
            // 이미 로드되었으면 재요청하지 않음
            guard !state.hasLoadedTodayAuthor else { return }
            
            Task {
                do {
                    state.isLoading = true
                    state.error = nil
                    let response = try await filterRepository.fetchTodayAuthor()
                    state.todayAuthor = response.author
                    state.hasLoadedTodayAuthor = true
                    state.isLoading = false
                } catch {
                    state.error = error
                    state.isLoading = false
                }
            }
            
        case .setTodayAuthor(let author):
            state.todayAuthor = author
            
        case .toggleLike(let filterId):
            Task {
                await toggleLike(filterId: filterId)
            }
            
        // MARK: - 강제 새로고침 케이스들
        case .refreshTodayFilter:
            state.hasLoadedTodayFilter = false
            dispatch(.fetchTodayFilter)
            
        case .refreshHotTrendFilters:
            state.hasLoadedHotTrendFilters = false
            dispatch(.fetchHotTrendFilters)
            
        case .refreshTodayAuthor:
            state.hasLoadedTodayAuthor = false
            dispatch(.fetchTodayAuthor)
        }
    }
    
    // MARK: - Private Methods
    private func toggleLike(filterId: String) async {
        let currentlyLiked = state.likedFilterIds.contains(filterId)
        
        // 옵티미스틱 업데이트
        if currentlyLiked {
            state.likedFilterIds.remove(filterId)
        } else {
            state.likedFilterIds.insert(filterId)
        }
        
        do {
            let newLikeStatus = try await toggleLikeUseCase.execute(
                filterId: filterId, 
                currentlyLiked: currentlyLiked
            )
            
            // 서버 응답에 따라 최종 상태 동기화
            if newLikeStatus {
                state.likedFilterIds.insert(filterId)
            } else {
                state.likedFilterIds.remove(filterId)
            }
            
            print("✅ [MainStore] Filter like status updated: \(filterId) -> \(newLikeStatus)")
        } catch {
            // 실패 시 롤백
            if currentlyLiked {
                state.likedFilterIds.insert(filterId)
            } else {
                state.likedFilterIds.remove(filterId)
            }
            print("❌ [MainStore] Error toggling like: \(error)")
        }
    }
} 