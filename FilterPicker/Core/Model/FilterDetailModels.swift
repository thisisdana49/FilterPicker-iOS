//
//  FilterDetailModels.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

// MARK: - Filter Detail Response
struct FilterDetailResponse: Codable, Equatable {
    let filterId: String
    let category: String
    let title: String
    let description: String
    let files: [String]
    let price: Int
    let creator: Creator
    let photoMetadata: PhotoMetadata
    let filterValues: FilterValues
    let isLiked: Bool
    let isDownloaded: Bool
    let likeCount: Int
    let buyerCount: Int
    let comments: [Comment]
    let createdAt: String
    let updatedAt: String
    
    // Equatable 구현
    static func == (lhs: FilterDetailResponse, rhs: FilterDetailResponse) -> Bool {
        return lhs.filterId == rhs.filterId &&
               lhs.isLiked == rhs.isLiked &&
               lhs.likeCount == rhs.likeCount &&
               lhs.title == rhs.title
    }
    
    // UI에서 사용하기 위한 computed properties
    /// 필터가 적용된 이미지 URL (첫 번째 파일)
    var filteredImageURL: String {
        guard let firstFile = files.first else { return "" }
        return AppConfig.baseURL + "/v1/" + firstFile
    }
    
    /// 원본 이미지 URL (두 번째 파일, 없으면 첫 번째 파일)
    var originalImageURL: String {
        let targetFile = files.last ?? files.first ?? ""
        guard !targetFile.isEmpty else { return "" }
        return AppConfig.baseURL + "/v1/" + targetFile
    }
    
    enum CodingKeys: String, CodingKey {
        case filterId = "filter_id"
        case category, title, description, files, price, creator
        case photoMetadata, filterValues
        case isLiked = "is_liked"
        case isDownloaded = "is_downloaded"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case comments, createdAt, updatedAt
    }
}

// MARK: - Filter Values
struct FilterValues: Codable, Equatable {
    let brightness: Double
    let exposure: Double
    let contrast: Double
    let saturation: Double
    let sharpness: Double
    let blur: Double
    let vignette: Double
    let noiseReduction: Double
    let highlights: Double
    let shadows: Double
    let temperature: Double
    let blackPoint: Double
    
    enum CodingKeys: String, CodingKey {
        case brightness, exposure, contrast, saturation, sharpness, blur, vignette
        case noiseReduction = "noise_reduction"
        case highlights, shadows, temperature
        case blackPoint = "black_point"
    }
}

// MARK: - Comment
struct Comment: Codable, Identifiable, Equatable {
    let id: String
    let content: String
    let createdAt: String
    let creator: Creator
    let replies: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case id = "comment_id"
        case content, createdAt, creator, replies
    }
}

// MARK: - API Request
struct FilterDetailRequest {
    let filterId: String
    
    var path: String {
        return "/v1/filters/\(filterId)"
    }
}

// MARK: - Address Info
class AddressInfo: NSObject, Codable {
    let formattedAddress: String
    let locality: String? // 시/구
    let subLocality: String? // 동/면
    let thoroughfare: String? // 도로명
    let subThoroughfare: String? // 번지
    let country: String?
    let countryCode: String?
    
    init(formattedAddress: String, locality: String?, subLocality: String?, thoroughfare: String?, subThoroughfare: String?, country: String?, countryCode: String?) {
        self.formattedAddress = formattedAddress
        self.locality = locality
        self.subLocality = subLocality
        self.thoroughfare = thoroughfare
        self.subThoroughfare = subThoroughfare
        self.country = country
        self.countryCode = countryCode
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        formattedAddress = try container.decode(String.self, forKey: .formattedAddress)
        locality = try container.decodeIfPresent(String.self, forKey: .locality)
        subLocality = try container.decodeIfPresent(String.self, forKey: .subLocality)
        thoroughfare = try container.decodeIfPresent(String.self, forKey: .thoroughfare)
        subThoroughfare = try container.decodeIfPresent(String.self, forKey: .subThoroughfare)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        super.init()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(formattedAddress, forKey: .formattedAddress)
        try container.encodeIfPresent(locality, forKey: .locality)
        try container.encodeIfPresent(subLocality, forKey: .subLocality)
        try container.encodeIfPresent(thoroughfare, forKey: .thoroughfare)
        try container.encodeIfPresent(subThoroughfare, forKey: .subThoroughfare)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(countryCode, forKey: .countryCode)
    }
    
    private enum CodingKeys: String, CodingKey {
        case formattedAddress, locality, subLocality, thoroughfare, subThoroughfare, country, countryCode
    }
    
    var displayAddress: String {
        if !formattedAddress.isEmpty {
            return formattedAddress
        }
        
        // Fallback: 구성 요소들로 주소 만들기
        var components: [String] = []
        
        if let locality = locality { components.append(locality) }
        if let subLocality = subLocality { components.append(subLocality) }
        if let thoroughfare = thoroughfare { components.append(thoroughfare) }
        if let subThoroughfare = subThoroughfare { components.append(subThoroughfare) }
        
        return components.joined(separator: " ")
    }
} 