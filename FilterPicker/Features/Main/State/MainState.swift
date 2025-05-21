import Foundation

struct MainState {
    var todayFilter: TodayFilterResponse?
    var hotTrendFilters: [HotTrendFilter] = []
    var todayAuthor: TodayAuthor?
    var isLoading: Bool = false
    var error: Error?
    
    static let initial = MainState()
} 