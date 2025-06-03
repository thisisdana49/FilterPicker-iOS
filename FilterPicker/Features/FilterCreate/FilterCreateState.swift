//
//  FilterCreateState.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

// MARK: - FilterCreateState
struct FilterCreateState {
    var filterName: String = ""
    var selectedCategory: FilterCategory? = nil
    var selectedImage: UIImage? = nil
    var filteredImage: UIImage? = nil                    // 필터 적용된 이미지
    var photoMetadata: PhotoMetadata? = nil              // 추출된 메타데이터
    var filterDescription: String = ""
    var price: String = "1000"
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isImagePickerPresented: Bool = false
    var isExtractingMetadata: Bool = false  // 메타데이터 추출 중 표시
    
    // 유효성 검사
    var isValid: Bool {
        return !filterName.isEmpty &&
               selectedCategory != nil &&
               selectedImage != nil &&
               !filterDescription.isEmpty &&
               !price.isEmpty &&
               Int(price) != nil &&
               Int(price)! > 0 &&
               photoMetadata != nil
    }
} 