import Foundation

// MARK: - Response Models

struct UserProfileResponse: Codable {
    // 필수 값
    let userId: String
    let email: String
    let nick: String
    let hashTags: [String]
    
    // 선택적 값
    let name: String?
    let introduction: String?
    let profileImage: String?
    let phoneNum: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nick
        case name
        case introduction
        case profileImage
        case phoneNum
        case hashTags
    }
}

// MARK: - Request Models

struct EditProfileRequest: Codable {
    let name: String?
    let introduction: String?
    let profileImage: String?
    let phoneNum: String?
    let hashTags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case introduction
        case profileImage
        case phoneNum
        case hashTags
    }
}

struct ImageUploadResponse: Codable {
    let imageURL: String
} 
