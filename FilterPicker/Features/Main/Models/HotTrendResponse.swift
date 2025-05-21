import Foundation

struct Creator: Codable {
    let userId: String
    let nick: String
    let name: String
    let introduction: String
    let profileImage: String?
    let hashTags: [String]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick, name, introduction, profileImage, hashTags
    }
}

struct HotTrendFilter: Codable {
    let filterId: String
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
