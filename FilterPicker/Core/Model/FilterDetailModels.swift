//
//  FilterDetailModels.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

// MARK: - Filter Detail Response
struct FilterDetailResponse: Codable {
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

// MARK: - Photo Metadata
struct PhotoMetadata: Codable {
    let camera: String
    let lensInfo: String
    let focalLength: Int
    let aperture: Double
    let iso: Int
    let shutterSpeed: String
    let pixelWidth: Int
    let pixelHeight: Int
    let fileSize: Int
    let format: String
    let dateTimeOriginal: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case camera
        case lensInfo = "lens_info"
        case focalLength = "focal_length"
        case aperture, iso
        case shutterSpeed = "shutter_speed"
        case pixelWidth = "pixel_width"
        case pixelHeight = "pixel_height"
        case fileSize = "file_size"
        case format
        case dateTimeOriginal = "date_time_original"
        case latitude, longitude
    }
}

// MARK: - Filter Values
struct FilterValues: Codable {
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
struct Comment: Codable, Identifiable {
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