//
//  FilterDetailUseCases.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

// MARK: - Get Filter Detail UseCase
protocol GetFilterDetailUseCase {
    func execute(filterId: String) async throws -> FilterDetailResponse
}

final class DefaultGetFilterDetailUseCase: GetFilterDetailUseCase {
    private let repository: FilterDetailRepository
    
    init(repository: FilterDetailRepository = DefaultFilterDetailRepository()) {
        self.repository = repository
    }
    
    func execute(filterId: String) async throws -> FilterDetailResponse {
        return try await repository.getFilterDetail(filterId: filterId)
    }
}

// MARK: - Toggle Filter Like UseCase
protocol ToggleFilterDetailLikeUseCase {
    func execute(filterId: String) async throws
}

final class DefaultToggleFilterDetailLikeUseCase: ToggleFilterDetailLikeUseCase {
    private let repository: FilterDetailRepository
    
    init(repository: FilterDetailRepository = DefaultFilterDetailRepository()) {
        self.repository = repository
    }
    
    func execute(filterId: String) async throws {
        try await repository.toggleLike(filterId: filterId)
    }
} 