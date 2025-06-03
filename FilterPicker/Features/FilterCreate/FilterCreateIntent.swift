//
//  FilterCreateIntent.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI
import Photos

enum FilterCreateIntent {
    case updateFilterName(String)
    case selectCategory(FilterCategory)
    case presentImagePicker
    case dismissImagePicker
    case selectImage(UIImage, PHAsset?)
    case setFilteredImage(UIImage)
    case setFilterParameters(FilterParameters)
    case startExtractingMetadata
    case setPhotoMetadata(PhotoMetadata)
    case metadataExtractionFailed
    case updateFilterDescription(String)
    case updatePrice(String)
    case saveFilter
    case clearError
} 