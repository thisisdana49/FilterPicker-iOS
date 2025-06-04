//
//  PhotoMetadata.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import Foundation

// MARK: - PhotoMetadata
struct PhotoMetadata: Codable, Equatable {
    let camera: String?
    let lensInfo: String?
    let focalLength: Double?
    let aperture: Double?
    let iso: Int?
    let shutterSpeed: String?
    let pixelWidth: Int
    let pixelHeight: Int
    let fileSize: Int64
    let format: String
    let dateTimeOriginal: String?
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case camera
        case lensInfo = "lens_info"
        case focalLength = "focal_length"
        case aperture
        case iso
        case shutterSpeed = "shutter_speed"
        case pixelWidth = "pixel_width"
        case pixelHeight = "pixel_height"
        case fileSize = "file_size"
        case format
        case dateTimeOriginal = "date_time_original"
        case latitude
        case longitude
    }
    
    init(
        camera: String? = nil,
        lensInfo: String? = nil,
        focalLength: Double? = nil,
        aperture: Double? = nil,
        iso: Int? = nil,
        shutterSpeed: String? = nil,
        pixelWidth: Int = 0,
        pixelHeight: Int = 0,
        fileSize: Int64 = 0,
        format: String = "JPEG",
        dateTimeOriginal: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.camera = camera
        self.lensInfo = lensInfo
        self.focalLength = focalLength
        self.aperture = aperture
        self.iso = iso
        self.shutterSpeed = shutterSpeed
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.fileSize = fileSize
        self.format = format
        self.dateTimeOriginal = dateTimeOriginal
        self.latitude = latitude
        self.longitude = longitude
    }
} 