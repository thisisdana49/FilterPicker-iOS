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
    var imageMetadata: ImageMetadata? = nil
    var filterDescription: String = ""
    var price: String = "1,000"
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isImagePickerPresented: Bool = false
    
    // 유효성 검사
    var isValid: Bool {
        !filterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedImage != nil &&
        !filterDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - ImageMetadata
struct ImageMetadata {
    let deviceModel: String
    let lensInfo: String
    let resolution: String
    let fileSize: String
    let location: String?
} 