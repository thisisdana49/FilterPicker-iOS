//
//  FilterFeedView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct FilterFeedView: View {
  @State private var selectedRankingType: FilterRankingType = .popularity
  @State private var likedFilters: Set<String> = Set(MockData.filterFeedItems.filter { $0.isLiked }.map { $0.id })
  
  // 더미 데이터
  private let topRankingData = MockData.mockTopRankingResponse
  private let filterFeedData = MockData.mockFilterFeedResponse
  
  var body: some View {
    VStack(spacing: 0) {
      // 커스텀 네비게이션 바
      CustomNavigationBar(
        title: "FEED",
        showBackButton: true,
        onBackTapped: {
          // 뒤로가기 액션 (향후 라우터 연동)
          print("Back tapped")
        }
      )
      
      // 메인 콘텐츠
      ScrollView {
        VStack(spacing: 40) {
          // Top Ranking 섹션
          TopRankingSectionView(
            selectedRankingType: $selectedRankingType,
            popularityRanking: topRankingData.popularityRanking,
            purchaseRanking: topRankingData.purchaseRanking,
            latestRanking: topRankingData.latestRanking,
            onFilterTapped: { filter in
              print("Top ranking filter tapped: \(filter.title)")
              // 필터 상세 화면으로 이동 (향후 구현)
            }
          )
          .padding(.top, 20)
          
          // Filter Feed 섹션
          FilterFeedSectionView(
            filters: updatedFilterFeedItems,
            onFilterTapped: { filter in
              print("Filter feed item tapped: \(filter.title)")
              // 필터 상세 화면으로 이동 (향후 구현)
            },
            onLikeTapped: { filter in
              toggleLike(for: filter)
            }
          )
        }
        .padding(.bottom, 100) // 탭바 영역을 위한 패딩
      }
    }
    .background(Color.black)
    .navigationBarHidden(true)
  }
  
  // MARK: - Helper Methods
  
  private var updatedFilterFeedItems: [Filter] {
    return filterFeedData.filters.map { filter in
      var updatedFilter = filter
      updatedFilter = Filter(
        id: filter.id,
        title: filter.title,
        creatorName: filter.creatorName,
        thumbnailURL: filter.thumbnailURL,
        imageURL: filter.imageURL,
        hashtags: filter.hashtags,
        likeCount: filter.likeCount,
        isLiked: likedFilters.contains(filter.id),
        ranking: filter.ranking,
        category: filter.category,
        createdAt: filter.createdAt,
        updatedAt: filter.updatedAt
      )
      return updatedFilter
    }
  }
  
  private func toggleLike(for filter: Filter) {
    withAnimation(.easeInOut(duration: 0.2)) {
      if likedFilters.contains(filter.id) {
        likedFilters.remove(filter.id)
      } else {
        likedFilters.insert(filter.id)
      }
    }
    
    // 향후 API 호출 추가
    print("Toggled like for filter: \(filter.title), isLiked: \(likedFilters.contains(filter.id))")
  }
}

#Preview {
  FilterFeedView()
} 