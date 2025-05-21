import Foundation

struct MainState {
    var todayFilter: TodayFilterResponse?
    var isLoading: Bool = false
    var error: Error?
    
    static let initial = MainState()
} 