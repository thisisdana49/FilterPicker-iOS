import Foundation

@MainActor
final class MainStore: ObservableObject {
    @Published private(set) var state: MainState
    private let filterRepository: FilterRepositoryProtocol
    
    init(
        initialState: MainState = .initial,
        filterRepository: FilterRepositoryProtocol = FilterRepository()
    ) {
        self.state = initialState
        self.filterRepository = filterRepository
    }
    
    func dispatch(_ intent: MainIntent) {
        switch intent {
        case .fetchTodayFilter:
            Task {
                do {
                    state.isLoading = true
                    state.error = nil
                    let todayFilter = try await filterRepository.fetchTodayFilter()
                    state.todayFilter = todayFilter
                    state.isLoading = false
                } catch {
                    state.error = error
                    state.isLoading = false
                }
            }
            
        case .fetchHotTrendFilters:
            Task {
                do {
                    state.isLoading = true
                    state.error = nil
                    let filters = try await filterRepository.fetchHotTrendFilters()
                    state.hotTrendFilters = filters
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
            Task {
                do {
                    state.isLoading = true
                    state.error = nil
                    let response = try await filterRepository.fetchTodayAuthor()
                    state.todayAuthor = response.author
                    state.isLoading = false
                } catch {
                    state.error = error
                    state.isLoading = false
                }
            }
            
        case .setTodayAuthor(let author):
            state.todayAuthor = author
        }
    }
} 