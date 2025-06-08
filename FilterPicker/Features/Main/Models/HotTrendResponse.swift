import Foundation

struct HotTrendFilter: Codable {
    let filterId: String
    let category: String?
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

    enum CodingKeys: String, CodingKey {
        case filterId = "filter_id"
        case category, title, description, files, creator
        case isLiked = "is_liked"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case createdAt, updatedAt
    }
}

struct HotTrendResponse: Codable {
    let data: [HotTrendFilter]
} 
