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
    private let getAddressUseCase: GetAddressFromCoordinatesUseCase
    
    init(
        getFilterDetailUseCase: GetFilterDetailUseCase = DefaultGetFilterDetailUseCase(),
        toggleLikeUseCase: ToggleFilterDetailLikeUseCase = DefaultToggleFilterDetailLikeUseCase(),
        getAddressUseCase: GetAddressFromCoordinatesUseCase = GetAddressFromCoordinatesUseCase()
    ) {
        self.getFilterDetailUseCase = getFilterDetailUseCase
        self.toggleLikeUseCase = toggleLikeUseCase
        self.getAddressUseCase = getAddressUseCase
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
                let newLikeStatus = try await toggleLikeUseCase.execute(filterId: filterId, currentlyLiked: originalIsLiked)
                
                // 서버 응답에 따라 최종 상태 동기화
                let finalDetail = FilterDetailResponse(
                    filterId: currentDetail.filterId,
                    category: currentDetail.category,
                    title: currentDetail.title,
                    description: currentDetail.description,
                    files: currentDetail.files,
                    price: currentDetail.price,
                    creator: currentDetail.creator,
                    photoMetadata: currentDetail.photoMetadata,
                    filterValues: currentDetail.filterValues,
                    isLiked: newLikeStatus,
                    isDownloaded: currentDetail.isDownloaded,
                    likeCount: newLikeStatus ? originalLikeCount + 1 : originalLikeCount - 1,
                    buyerCount: currentDetail.buyerCount,
                    comments: currentDetail.comments,
                    createdAt: currentDetail.createdAt,
                    updatedAt: currentDetail.updatedAt
                )
                newState.filterDetail = finalDetail
                newState.isLikeLoading = false
                print("✅ 좋아요 토글 성공: \(newLikeStatus)")
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
            
        case .loadAddress(let latitude, let longitude):
            newState.isLoadingAddress = true
            newState.addressError = nil
            
            do {
                let addressInfo = try await getAddressUseCase.execute(latitude: latitude, longitude: longitude)
                newState.addressInfo = addressInfo
                newState.isLoadingAddress = false
                print("✅ 주소 조회 성공: \(addressInfo.displayAddress)")
            } catch {
                newState.addressError = error
                newState.isLoadingAddress = false
                print("❌ 주소 조회 실패: \(error.localizedDescription)")
            }
        }
        
        return newState
    }
} 