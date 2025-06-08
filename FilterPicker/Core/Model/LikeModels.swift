//
//  LikeModels.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

// MARK: - Like Request
struct LikeRequest: Codable {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}

// MARK: - Like Response
struct LikeResponse: Codable {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
} 