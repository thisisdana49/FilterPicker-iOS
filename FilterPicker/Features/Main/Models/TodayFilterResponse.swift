import Foundation

struct TodayFilterResponse: Codable {
    let filterId: String
    let title: String
    let introduction: String
    let description: String
    let files: [String]
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case filterId = "filter_id"
        case title
        case introduction
        case description
        case files
        case createdAt
        case updatedAt
    }
} 
