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
    var selectedCategory: FilterCategory = .portrait
    var selectedImage: UIImage? = nil
    var photoMetadata: PhotoMetadata? = nil
    var filterDescription: String = ""
    var price: String = "1,000"
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isImagePickerPresented: Bool = false
    var isExtractingMetadata: Bool = false  // 메타데이터 추출 중 표시
    
    // 유효성 검사
    var isValid: Bool {
        !filterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedImage != nil &&
        !filterDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
} 