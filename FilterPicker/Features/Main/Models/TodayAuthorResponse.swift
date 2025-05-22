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

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick, name, profileImage, hashTags, introduction, description
    }
}

struct TodayAuthorResponse: Codable {
    let author: TodayAuthor
    let filters: [HotTrendFilter]
} 
