import Foundation

struct MainState {
    var todayFilter: TodayFilterResponse?
    var hotTrendFilters: [HotTrendFilter] = []
    var todayAuthor: TodayAuthor?
    var isLoading: Bool = false
    var error: Error?
    var likedFilterIds: Set<String> = []
    
    // 초기 로드 상태 추가
    var hasLoadedTodayFilter: Bool = false
    var hasLoadedHotTrendFilters: Bool = false
    var hasLoadedTodayAuthor: Bool = false
    
    // MARK: - Computed Properties
    var updatedHotTrendFilters: [HotTrendFilter] {
        return hotTrendFilters.map { filter in
            HotTrendFilter(
                filterId: filter.filterId,
                category: filter.category,
                title: filter.title,
                description: filter.description,
                files: filter.files,
                creator: filter.creator,
                isLiked: likedFilterIds.contains(filter.filterId),
                likeCount: filter.likeCount,
                buyerCount: filter.buyerCount,
                createdAt: filter.createdAt,
                updatedAt: filter.updatedAt
            )
        }
    }
    
    static let initial = MainState()
} 