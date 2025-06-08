//
//  Filter.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

// MARK: - Filter Models
struct Filter: Identifiable, Codable, Equatable {
  let id: String
  let category: String
  let title: String
  let description: String
  let files: [String]
  let creator: Creator
  let isLiked: Bool
  let likeCount: Int
  let buyerCount: Int
  let createdAt: String
  let updatedAt: String
  
  // UI에서 사용하기 위한 computed properties
  /// 필터가 적용된 이미지 URL (첫 번째 파일)
  var filteredImageURL: String {
    guard let firstFile = files.first else { return "" }
    return AppConfig.baseURL + "/v1" + firstFile
  }
  
  /// 원본 이미지 URL (두 번째 파일, 없으면 첫 번째 파일)
  var originalImageURL: String {
    let targetFile = files.last ?? files.first ?? ""
    guard !targetFile.isEmpty else { return "" }
    return AppConfig.baseURL + "/v1" + targetFile
  }
  
  // MARK: - Legacy computed properties (backward compatibility)
  @available(*, deprecated, renamed: "filteredImageURL")
  var thumbnailURL: String {
    return filteredImageURL
  }
  
  @available(*, deprecated, renamed: "originalImageURL")  
  var fullImageURL: String {
    return originalImageURL
  }
  
  var hashtags: [String] {
    return creator.hashTags
  }
  
  var creatorName: String {
    return creator.nick
  }
  
  var ranking: Int? {
    return nil // 별도 API에서 제공
  }
  
  enum CodingKeys: String, CodingKey {
    case id = "filter_id"
    case category
    case title
    case description
    case files
    case creator
    case isLiked = "is_liked"
    case likeCount = "like_count"
    case buyerCount = "buyer_count"
    case createdAt
    case updatedAt
  }
}

// MARK: - Filter Category
enum FilterCategory: String, CaseIterable, Codable, Equatable {
  case food = "푸드"
  case portrait = "인물"
  case landscape = "풍경"
  case night = "야경"
  case star = "별"
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
enum FilterRankingType: String, CaseIterable, Equatable {
  case popularity = "인기순"
  case purchase = "구매순"
  case latest = "최신순"
  
  var apiValue: String {
    switch self {
    case .popularity:
      return "popularity"
    case .purchase:
      return "purchase"
    case .latest:
      return "latest"
    }
  }
  
  var displayName: String {
    return self.rawValue
  }
}

// MARK: - API Request Models
struct FilterListRequest {
  let next: String?
  let limit: Int
  let category: String?
  let orderBy: String
  
  init(
    next: String? = nil,
    limit: Int = 5,
    category: String? = nil,
    orderBy: FilterRankingType = .latest
  ) {
    self.next = next
    self.limit = limit
    self.category = category
    self.orderBy = orderBy.apiValue
  }
  
  var queryItems: [URLQueryItem] {
    var items: [URLQueryItem] = [
      URLQueryItem(name: "limit", value: "\(limit)"),
      URLQueryItem(name: "order_by", value: orderBy)
    ]
    
    if let next = next, !next.isEmpty {
      items.append(URLQueryItem(name: "next", value: next))
    }
    
    if let category = category, !category.isEmpty {
      items.append(URLQueryItem(name: "category", value: category))
    }
    
    return items
  }
}

// MARK: - API Response Models
struct FilterListResponse: Codable {
  let data: [Filter]
  let nextCursor: String
  
  var hasNext: Bool {
    return nextCursor != "0"
  }
  
  enum CodingKeys: String, CodingKey {
    case data
    case nextCursor = "next_cursor"
  }
}

// MARK: - Legacy Models (기존 Mock 데이터용)
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
