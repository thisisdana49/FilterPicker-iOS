//
//  PhotoMetadataExtractor.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import UIKit
import ImageIO
import CoreLocation
import Photos

class PhotoMetadataExtractor {
    
    // MARK: - Public Methods
    
    /// UIImage에서 메타데이터 추출 (제한적)
    func extractMetadata(from image: UIImage) -> PhotoMetadata {
        return PhotoMetadata(
            pixelWidth: Int(image.size.width * image.scale),
            pixelHeight: Int(image.size.height * image.scale),
            format: "JPEG"
        )
    }
    
    /// 이미지 데이터에서 메타데이터 추출 (권장)
    func extractMetadata(from imageData: Data) -> PhotoMetadata {
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
              let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            return extractBasicMetadata(from: imageData)
        }
        
        return parseImageProperties(imageProperties, imageData: imageData)
    }
    
    /// PHAsset에서 메타데이터 추출 (가장 정확)
    func extractMetadata(from asset: PHAsset, completion: @escaping (PhotoMetadata?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [weak self] data, _, _, _ in
            guard let self = self, let imageData = data else {
                completion(nil)
                return
            }
            
            let metadata = self.extractMetadata(from: imageData)
            completion(metadata)
        }
    }
    
    // MARK: - Private Methods
    
    private func extractBasicMetadata(from imageData: Data) -> PhotoMetadata {
        guard let image = UIImage(data: imageData) else {
            return PhotoMetadata()
        }
        
        return PhotoMetadata(
            pixelWidth: Int(image.size.width * image.scale),
            pixelHeight: Int(image.size.height * image.scale),
            fileSize: Int64(imageData.count),
            format: detectImageFormat(from: imageData)
        )
    }
    
    private func parseImageProperties(_ properties: [String: Any], imageData: Data) -> PhotoMetadata {
        // EXIF 데이터
        let exifData = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        let tiffData = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
        let gpsData = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any]
        
        // 기본 이미지 정보
        let pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int ?? 0
        let pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int ?? 0
        
        // 카메라 정보
        let camera = extractCameraInfo(from: tiffData)
        let lensInfo = exifData?[kCGImagePropertyExifLensModel as String] as? String
        
        // 촬영 설정
        let focalLength = exifData?[kCGImagePropertyExifFocalLength as String] as? Double
        let aperture = exifData?[kCGImagePropertyExifFNumber as String] as? Double
        let iso = exifData?[kCGImagePropertyExifISOSpeedRatings as String] as? [Int]
        let shutterSpeed = extractShutterSpeed(from: exifData)
        
        // 날짜 정보
        let dateTimeOriginal = extractDateTime(from: exifData)
        
        // 위치 정보
        let (latitude, longitude) = extractGPSInfo(from: gpsData)
        
        return PhotoMetadata(
            camera: camera,
            lensInfo: lensInfo,
            focalLength: focalLength,
            aperture: aperture,
            iso: iso?.first,
            shutterSpeed: shutterSpeed,
            pixelWidth: pixelWidth,
            pixelHeight: pixelHeight,
            fileSize: Int64(imageData.count),
            format: detectImageFormat(from: imageData),
            dateTimeOriginal: dateTimeOriginal,
            latitude: latitude,
            longitude: longitude
        )
    }
    
    private func extractCameraInfo(from tiffData: [String: Any]?) -> String? {
        guard let tiffData = tiffData else { return nil }
        
        let make = tiffData[kCGImagePropertyTIFFMake as String] as? String ?? ""
        let model = tiffData[kCGImagePropertyTIFFModel as String] as? String ?? ""
        
        if !make.isEmpty && !model.isEmpty {
            return "\(make) \(model)".trimmingCharacters(in: .whitespaces)
        } else if !model.isEmpty {
            return model
        }
        
        return nil
    }
    
    private func extractShutterSpeed(from exifData: [String: Any]?) -> String? {
        guard let exifData = exifData,
              let exposureTime = exifData[kCGImagePropertyExifExposureTime as String] as? Double else {
            return nil
        }
        
        if exposureTime >= 1 {
            return String(format: "%.1f sec", exposureTime)
        } else {
            let denominator = Int(1.0 / exposureTime)
            return "1/\(denominator) sec"
        }
    }
    
    private func extractDateTime(from exifData: [String: Any]?) -> String? {
        guard let exifData = exifData,
              let dateTimeString = exifData[kCGImagePropertyExifDateTimeOriginal as String] as? String else {
            return nil
        }
        
        // "YYYY:MM:DD HH:MM:SS" -> ISO 8601 형식으로 변환
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        if let date = formatter.date(from: dateTimeString) {
            let isoFormatter = ISO8601DateFormatter()
            return isoFormatter.string(from: date)
        }
        
        return nil
    }
    
    private func extractGPSInfo(from gpsData: [String: Any]?) -> (latitude: Double?, longitude: Double?) {
        guard let gpsData = gpsData,
              let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef as String] as? String,
              let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef as String] as? String,
              let latitude = gpsData[kCGImagePropertyGPSLatitude as String] as? Double,
              let longitude = gpsData[kCGImagePropertyGPSLongitude as String] as? Double else {
            return (nil, nil)
        }
        
        let finalLatitude = (latitudeRef == "S") ? -latitude : latitude
        let finalLongitude = (longitudeRef == "W") ? -longitude : longitude
        
        return (finalLatitude, finalLongitude)
    }
    
    private func detectImageFormat(from imageData: Data) -> String {
        guard imageData.count >= 12 else { return "UNKNOWN" }
        
        let bytes = imageData.prefix(12)
        
        // JPEG
        if bytes.starts(with: [0xFF, 0xD8, 0xFF]) {
            return "JPEG"
        }
        
        // PNG
        if bytes.starts(with: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) {
            return "PNG"
        }
        
        // HEIF/HEIC
        if bytes.count >= 12 {
            let heifSignature = Data(bytes[4..<12])
            if heifSignature.starts(with: "ftypheic".data(using: .ascii) ?? Data()) ||
               heifSignature.starts(with: "ftypmif1".data(using: .ascii) ?? Data()) {
                return "HEIC"
            }
        }
        
        return "UNKNOWN"
    }
} 