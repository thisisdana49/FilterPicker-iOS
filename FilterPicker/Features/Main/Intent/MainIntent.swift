import Foundation

enum MainIntent {
    case fetchTodayFilter
    case fetchHotTrendFilters
    case setTodayFilter(TodayFilterResponse)
    case setHotTrendFilters([HotTrendFilter])
    case setLoading(Bool)
    case setError(Error?)
} 