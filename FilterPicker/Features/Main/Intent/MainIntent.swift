import Foundation

enum MainIntent {
    case fetchTodayFilter
    case setTodayFilter(TodayFilterResponse)
    case setLoading(Bool)
    case setError(Error?)
} 