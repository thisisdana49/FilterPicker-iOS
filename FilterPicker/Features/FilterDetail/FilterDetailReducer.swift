//
//  FilterDetailReducer.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

struct FilterDetailReducer {
    private let getFilterDetailUseCase: GetFilterDetailUseCase
    private let toggleLikeUseCase: ToggleFilterDetailLikeUseCase
    
    init(
        getFilterDetailUseCase: GetFilterDetailUseCase = DefaultGetFilterDetailUseCase(),
        toggleLikeUseCase: ToggleFilterDetailLikeUseCase = DefaultToggleFilterDetailLikeUseCase()
    ) {
        self.getFilterDetailUseCase = getFilterDetailUseCase
        self.toggleLikeUseCase = toggleLikeUseCase
    }
    
    func reduce(state: FilterDetailState, intent: FilterDetailIntent) async -> FilterDetailState {
        var newState = state
        
        switch intent {
        case .loadFilterDetail(let filterId):
            newState.isLoading = true
            newState.error = nil
            
            do {
                let filterDetail = try await getFilterDetailUseCase.execute(filterId: filterId)
                newState.filterDetail = filterDetail
                newState.isLoading = false
                print("✅ 필터 상세 조회 성공: \(filterDetail.title)")
            } catch {
                newState.error = error
                newState.isLoading = false
                print("❌ 필터 상세 조회 실패: \(error.localizedDescription)")
            }
            
        case .refresh(let filterId):
            // 새로고침은 로딩 상태를 표시하지 않음
            do {
                let filterDetail = try await getFilterDetailUseCase.execute(filterId: filterId)
                newState.filterDetail = filterDetail
                newState.error = nil
                print("✅ 필터 상세 새로고침 성공")
            } catch {
                newState.error = error
                print("❌ 필터 상세 새로고침 실패: \(error.localizedDescription)")
            }
            
        case .toggleLike(let filterId):
            guard var currentDetail = newState.filterDetail else { return newState }
            
            newState.isLikeLoading = true
            
            // 옵티미스틱 업데이트
            let originalIsLiked = currentDetail.isLiked
            let originalLikeCount = currentDetail.likeCount
            
            currentDetail = FilterDetailResponse(
                filterId: currentDetail.filterId,
                category: currentDetail.category,
                title: currentDetail.title,
                description: currentDetail.description,
                files: currentDetail.files,
                price: currentDetail.price,
                creator: currentDetail.creator,
                photoMetadata: currentDetail.photoMetadata,
                filterValues: currentDetail.filterValues,
                isLiked: !originalIsLiked,
                isDownloaded: currentDetail.isDownloaded,
                likeCount: originalIsLiked ? originalLikeCount - 1 : originalLikeCount + 1,
                buyerCount: currentDetail.buyerCount,
                comments: currentDetail.comments,
                createdAt: currentDetail.createdAt,
                updatedAt: currentDetail.updatedAt
            )
            newState.filterDetail = currentDetail
            
            do {
                try await toggleLikeUseCase.execute(filterId: filterId)
                newState.isLikeLoading = false
                print("✅ 좋아요 토글 성공")
            } catch {
                // 실패 시 롤백
                let rolledBackDetail = FilterDetailResponse(
                    filterId: currentDetail.filterId,
                    category: currentDetail.category,
                    title: currentDetail.title,
                    description: currentDetail.description,
                    files: currentDetail.files,
                    price: currentDetail.price,
                    creator: currentDetail.creator,
                    photoMetadata: currentDetail.photoMetadata,
                    filterValues: currentDetail.filterValues,
                    isLiked: originalIsLiked,
                    isDownloaded: currentDetail.isDownloaded,
                    likeCount: originalLikeCount,
                    buyerCount: currentDetail.buyerCount,
                    comments: currentDetail.comments,
                    createdAt: currentDetail.createdAt,
                    updatedAt: currentDetail.updatedAt
                )
                newState.filterDetail = rolledBackDetail
                newState.isLikeLoading = false
                print("❌ 좋아요 토글 실패: \(error.localizedDescription)")
            }
        }
        
        return newState
    }
} 