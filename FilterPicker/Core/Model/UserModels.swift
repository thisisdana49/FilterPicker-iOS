//
//  UserModels.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

// MARK: - Creator Model
struct Creator: Codable, Equatable {
  let userId: String
  let nick: String
  let name: String
  let introduction: String
  let profileImage: String
  let hashTags: [String]
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case nick
    case name
    case introduction
    case profileImage
    case hashTags
  }
} 