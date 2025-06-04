//
//  ImageProcessor.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import UIKit

// MARK: - Upload Data Models

struct UploadImageData {
    let originalImageData: Data
    let filteredImageData: Data
    let metadata: PhotoMetadata
    
    var totalSize: Int64 {
        return Int64(originalImageData.count + filteredImageData.count)
    }
    
    var totalSizeKB: Double {
        return Double(totalSize) / 1024.0
    }
}

// MARK: - Image Processor

class ImageProcessor {
    
    // MARK: - Constants
    
    private static let MAX_UPLOAD_SIZE_KB = 512
    private static let MAX_DIMENSION: CGFloat = 1024
    private static let MIN_DIMENSION: CGFloat = 512
    private static let QUALITY_STEPS: [CGFloat] = [0.9, 0.8, 0.7, 0.6, 0.5]
    
    // MARK: - Public Methods
    
    /// 업로드용 이미지 데이터 생성 (원본 + 필터 적용)
    static func prepareForUpload(
        originalImage: UIImage,
        filteredImage: UIImage,
        metadata: PhotoMetadata
    ) -> UploadImageData? {
        print("🔄 업로드용 이미지 처리 시작...")
        print("  - 목표 크기: \(MAX_UPLOAD_SIZE_KB)KB 이하")
        
        // 1단계: 기본 해상도로 압축 시도
        if let result = attemptCompression(
            original: originalImage,
            filtered: filteredImage,
            metadata: metadata,
            maxDimension: MAX_DIMENSION
        ) {
            print("✅ 기본 해상도(\(MAX_DIMENSION)px)로 압축 성공: \(String(format: "%.1f", result.totalSizeKB))KB")
            return result
        }
        
        // 2단계: 해상도를 줄여서 재시도
        let reducedDimension = (MAX_DIMENSION + MIN_DIMENSION) / 2
        if let result = attemptCompression(
            original: originalImage,
            filtered: filteredImage,
            metadata: metadata,
            maxDimension: reducedDimension
        ) {
            print("✅ 축소 해상도(\(reducedDimension)px)로 압축 성공: \(String(format: "%.1f", result.totalSizeKB))KB")
            return result
        }
        
        // 3단계: 최소 해상도로 마지막 시도
        if let result = attemptCompression(
            original: originalImage,
            filtered: filteredImage,
            metadata: metadata,
            maxDimension: MIN_DIMENSION
        ) {
            print("✅ 최소 해상도(\(MIN_DIMENSION)px)로 압축 성공: \(String(format: "%.1f", result.totalSizeKB))KB")
            return result
        }
        
        print("❌ 모든 압축 시도 실패 - 512KB 이하로 압축 불가")
        return nil
    }
    
    // MARK: - Private Methods
    
    private static func attemptCompression(
        original: UIImage,
        filtered: UIImage,
        metadata: PhotoMetadata,
        maxDimension: CGFloat
    ) -> UploadImageData? {
        
        // 이미지 리사이즈
        let resizedOriginal = resizeImage(original, maxDimension: maxDimension)
        let resizedFiltered = resizeImage(filtered, maxDimension: maxDimension)
        
        // 품질별 압축 시도
        for quality in QUALITY_STEPS {
            guard let originalData = compressImage(resizedOriginal, quality: quality),
                  let filteredData = compressImage(resizedFiltered, quality: quality) else {
                continue
            }
            
            let totalSizeKB = Double(originalData.count + filteredData.count) / 1024.0
            print("  - 품질 \(Int(quality * 100))%: \(String(format: "%.1f", totalSizeKB))KB")
            
            if totalSizeKB <= Double(MAX_UPLOAD_SIZE_KB) {
                return UploadImageData(
                    originalImageData: originalData,
                    filteredImageData: filteredData,
                    metadata: metadata
                )
            }
        }
        
        return nil
    }
    
    /// 이미지를 지정된 최대 크기로 리사이즈
    private static func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if size.width > size.height {
            // 가로가 더 긴 경우
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // 세로가 더 긴 경우
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        // 이미 작은 이미지는 그대로 반환
        if size.width <= newSize.width && size.height <= newSize.height {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    /// JPEG 압축
    private static func compressImage(_ image: UIImage, quality: CGFloat) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
}

// MARK: - Upload Request Models

struct FilterUploadRequest: Codable {
    let name: String
    let description: String
    let category: String
    let price: Int
    let originalImage: String  // Base64 encoded
    let filteredImage: String  // Base64 encoded
    let metadata: PhotoMetadata
    
    private enum CodingKeys: String, CodingKey {
        case name = "filter_name"
        case description = "filter_description"
        case category = "filter_category"
        case price = "filter_price"
        case originalImage = "original_image"
        case filteredImage = "filtered_image"
        case metadata = "photo_metadata"
    }
} 