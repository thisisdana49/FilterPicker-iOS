//
//  TodayAuthor.swift
//  FilterPicker
//
//  Created by 조다은 on 5/21/25.
//


import Foundation

struct TodayAuthor: Codable {
    let userId: String
    let nick: String
    let name: String
    let profileImage: String?
    let hashTags: [String]
    let introduction: String
    let description: String
    
    // UI에서 사용하기 위한 computed properties
    /// 프로필 이미지 URL
    var profileImageURL: String {
        guard let profileImage = profileImage else { return "" }
        return AppConfig.baseURL + "/v1/" + profileImage
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick, name, profileImage, hashTags, introduction, description
    }
}

struct TodayAuthorResponse: Codable {
    let author: TodayAuthor
    let filters: [HotTrendFilter]
} 
