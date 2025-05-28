//
//  Filter.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

// MARK: - Filter Models
struct Filter: Identifiable, Codable {
  let id: String
  let title: String
  let creatorName: String
  let thumbnailURL: String
  let imageURL: String
  let hashtags: [String]
  let likeCount: Int
  let isLiked: Bool
  let ranking: Int?
  let category: FilterCategory
  let createdAt: Date
  let updatedAt: Date
}

// MARK: - Filter Category
enum FilterCategory: String, CaseIterable, Codable {
  case portrait = "인물"
  case landscape = "풍경"
  case street = "거리"
  case vintage = "빈티지"
  case film = "필름"
  case nature = "자연"
  case urban = "도시"
  case mood = "무드"
  
  var displayName: String {
    return self.rawValue
  }
}

// MARK: - Filter Ranking Type
enum FilterRankingType: String, CaseIterable {
  case popularity = "인기순"
  case purchase = "구매순"
  case latest = "최신순"
  
  var displayName: String {
    return self.rawValue
  }
}

// MARK: - Filter Response Models
struct FilterResponse: Codable {
  let filters: [Filter]
  let totalCount: Int
  let hasNext: Bool
}

struct TopRankingResponse: Codable {
  let popularityRanking: [Filter]
  let purchaseRanking: [Filter]
  let latestRanking: [Filter]
} 
