//
//  MockData.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

enum MockData {
  
  // MARK: - Mock Creator Data
  static let mockCreator1 = Creator(
    userId: "6816ee1c6d1bff703149336f",
    nick: "YOON SESAC",
    name: "윤새싹",
    introduction: "프로필 소개입니다.",
    profileImage: "/data/profiles/1712739634962.png",
    hashTags: ["#인물"]
  )
  
  static let mockCreator2 = Creator(
    userId: "6816ee1c6d1bff703149337g",
    nick: "SEO SAEROK",
    name: "서새록",
    introduction: "필터 전문가입니다.",
    profileImage: "/data/profiles/1712739634963.png",
    hashTags: ["#인물", "#무드"]
  )
  
  // MARK: - Top Ranking Mock Data
  static let topRankingFilters: [Filter] = [
    Filter(
      id: "rank_1",
      category: "인물",
      title: "정국 세죽",
      description: "정국의 매력을 더욱 돋보이게 하는 필터",
      files: [
        "https://picsum.photos/300/300?random=1",
        "https://picsum.photos/800/600?random=1"
      ],
      creator: mockCreator1,
      isLiked: false,
      likeCount: 2847,
      buyerCount: 847,
      createdAt: "2024-01-01T00:00:00.000Z",
      updatedAt: "2024-01-01T00:00:00.000Z"
    ),
    Filter(
      id: "rank_2",
      category: "빈티지",
      title: "빈티지 무드",
      description: "레트로한 감성의 빈티지 필터",
      files: [
        "https://picsum.photos/300/300?random=2",
        "https://picsum.photos/800/600?random=2"
      ],
      creator: mockCreator2,
      isLiked: true,
      likeCount: 1923,
      buyerCount: 523,
      createdAt: "2024-01-02T00:00:00.000Z",
      updatedAt: "2024-01-02T00:00:00.000Z"
    ),
    Filter(
      id: "rank_3",
      category: "도시",
      title: "도시 야경",
      description: "도시의 밤을 더욱 아름답게",
      files: [
        "https://picsum.photos/300/300?random=3",
        "https://picsum.photos/800/600?random=3"
      ],
      creator: mockCreator1,
      isLiked: false,
      likeCount: 1456,
      buyerCount: 356,
      createdAt: "2024-01-03T00:00:00.000Z",
      updatedAt: "2024-01-03T00:00:00.000Z"
    )
  ]
  
  // MARK: - Filter Feed Mock Data
  static let filterFeedItems: [Filter] = [
    Filter(
      id: "feed_1",
      category: "인물",
      title: "정연",
      description: "푸르른 여름저녁 마음에 스며드는, 고요하고 깊은 감성의 정복빛 필터",
      files: [
        "https://picsum.photos/300/300?random=11",
        "https://picsum.photos/800/600?random=11"
      ],
      creator: mockCreator1,
      isLiked: true,
      likeCount: 847,
      buyerCount: 247,
      createdAt: "2024-01-11T00:00:00.000Z",
      updatedAt: "2024-01-11T00:00:00.000Z"
    ),
    Filter(
      id: "feed_2",
      category: "인물",
      title: "춘담",
      description: "봄의 따뜻함을 담은 인물 필터",
      files: [
        "https://picsum.photos/300/300?random=12",
        "https://picsum.photos/800/600?random=12"
      ],
      creator: mockCreator1,
      isLiked: false,
      likeCount: 623,
      buyerCount: 123,
      createdAt: "2024-01-12T00:00:00.000Z",
      updatedAt: "2024-01-12T00:00:00.000Z"
    ),
    Filter(
      id: "feed_3",
      category: "인물",
      title: "시한월연",
      description: "시한 속의 아름다운 월연",
      files: [
        "https://picsum.photos/300/300?random=13",
        "https://picsum.photos/800/600?random=13"
      ],
      creator: mockCreator2,
      isLiked: true,
      likeCount: 394,
      buyerCount: 94,
      createdAt: "2024-01-13T00:00:00.000Z",
      updatedAt: "2024-01-13T00:00:00.000Z"
    ),
    Filter(
      id: "feed_4",
      category: "인물",
      title: "연리지",
      description: "연인들을 위한 로맨틱 필터",
      files: [
        "https://picsum.photos/300/300?random=14",
        "https://picsum.photos/800/600?random=14"
      ],
      creator: mockCreator2,
      isLiked: false,
      likeCount: 567,
      buyerCount: 167,
      createdAt: "2024-01-14T00:00:00.000Z",
      updatedAt: "2024-01-14T00:00:00.000Z"
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
  
  // MARK: - API Mock Response
  static let mockFilterListResponse = FilterListResponse(
    data: filterFeedItems,
    nextCursor: "655659b83913fe98de4b82d2"
  )
} 