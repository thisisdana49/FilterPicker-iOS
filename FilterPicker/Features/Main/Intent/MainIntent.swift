import Foundation

enum MainIntent {
    case fetchTodayFilter
    case fetchHotTrendFilters
    case fetchTodayAuthor
    case setTodayFilter(TodayFilterResponse)
    case setHotTrendFilters([HotTrendFilter])
    case setTodayAuthor(TodayAuthor)
    case setLoading(Bool)
    case setError(Error?)
    case toggleLike(String) // filterId
    
    // 강제 새로고침 케이스
    case refreshTodayFilter
    case refreshHotTrendFilters
    case refreshTodayAuthor
} 