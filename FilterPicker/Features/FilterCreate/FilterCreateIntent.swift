//
//  FilterCreateIntent.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

enum FilterCreateIntent {
    case updateFilterName(String)
    case selectCategory(FilterCategory)
    case presentImagePicker
    case dismissImagePicker
    case selectImage(UIImage)
    case updateImageMetadata(ImageMetadata)
    case updateFilterDescription(String)
    case updatePrice(String)
    case saveFilter
    case clearError
} 