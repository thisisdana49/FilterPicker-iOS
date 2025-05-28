//
//  MockData.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

enum MockData {
  
  // MARK: - Top Ranking Mock Data
  static let topRankingFilters: [Filter] = [
    Filter(
      id: "rank_1",
      title: "정국 세죽",
      creatorName: "YOON SESAC",
      thumbnailURL: "https://picsum.photos/300/300?random=1",
      imageURL: "https://picsum.photos/800/600?random=1",
      hashtags: ["#인물"],
      likeCount: 2847,
      isLiked: false,
      ranking: 1,
      category: .portrait,
      createdAt: Date(),
      updatedAt: Date()
    ),
    Filter(
      id: "rank_2",
      title: "빈티지 무드",
      creatorName: "PHOTO MASTER",
      thumbnailURL: "https://picsum.photos/300/300?random=2",
      imageURL: "https://picsum.photos/800/600?random=2",
      hashtags: ["#빈티지", "#무드"],
      likeCount: 1923,
      isLiked: true,
      ranking: 2,
      category: .vintage,
      createdAt: Date(),
      updatedAt: Date()
    ),
    Filter(
      id: "rank_3",
      title: "도시 야경",
      creatorName: "URBAN PHOTOGRAPHER",
      thumbnailURL: "https://picsum.photos/300/300?random=3",
      imageURL: "https://picsum.photos/800/600?random=3",
      hashtags: ["#도시", "#야경"],
      likeCount: 1456,
      isLiked: false,
      ranking: 3,
      category: .urban,
      createdAt: Date(),
      updatedAt: Date()
    )
  ]
  
  // MARK: - Filter Feed Mock Data
  static let filterFeedItems: [Filter] = [
    Filter(
      id: "feed_1",
      title: "정연",
      creatorName: "YOON SESAC",
      thumbnailURL: "https://picsum.photos/300/300?random=11",
      imageURL: "https://picsum.photos/800/600?random=11",
      hashtags: ["#인물"],
      likeCount: 847,
      isLiked: true,
      ranking: nil,
      category: .portrait,
      createdAt: Date(),
      updatedAt: Date()
    ),
    Filter(
      id: "feed_2",
      title: "춘담",
      creatorName: "YOON SESAC",
      thumbnailURL: "https://picsum.photos/300/300?random=12",
      imageURL: "https://picsum.photos/800/600?random=12",
      hashtags: ["#인물"],
      likeCount: 623,
      isLiked: false,
      ranking: nil,
      category: .portrait,
      createdAt: Date(),
      updatedAt: Date()
    ),
    Filter(
      id: "feed_3",
      title: "시한월연",
      creatorName: "SEO SAEROK",
      thumbnailURL: "https://picsum.photos/300/300?random=13",
      imageURL: "https://picsum.photos/800/600?random=13",
      hashtags: ["#인물"],
      likeCount: 394,
      isLiked: true,
      ranking: nil,
      category: .portrait,
      createdAt: Date(),
      updatedAt: Date()
    ),
    Filter(
      id: "feed_4",
      title: "연리지",
      creatorName: "SEO SAEROK",
      thumbnailURL: "https://picsum.photos/300/300?random=14",
      imageURL: "https://picsum.photos/800/600?random=14",
      hashtags: ["#인물"],
      likeCount: 567,
      isLiked: false,
      ranking: nil,
      category: .portrait,
      createdAt: Date(),
      updatedAt: Date()
    )
  ]
  
  // MARK: - Mock Response Data
  static let mockTopRankingResponse = TopRankingResponse(
    popularityRanking: topRankingFilters,
    purchaseRanking: topRankingFilters.shuffled(),
    latestRanking: topRankingFilters.reversed()
  )
  
  static let mockFilterFeedResponse = FilterResponse(
    filters: filterFeedItems,
    totalCount: 50,
    hasNext: true
  )
} 