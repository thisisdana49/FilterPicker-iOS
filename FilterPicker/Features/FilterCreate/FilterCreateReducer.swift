//
//  FilterCreateReducer.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

struct FilterCreateReducer {
    func reduce(state: inout FilterCreateState, intent: FilterCreateIntent) {
        switch intent {
        case .updateFilterName(let name):
            state.filterName = name
            
        case .selectCategory(let category):
            state.selectedCategory = category
            
        case .presentImagePicker:
            state.isImagePickerPresented = true
            
        case .dismissImagePicker:
            state.isImagePickerPresented = false
            
        case .selectImage(let image, let phAsset):
            state.selectedImage = image
            state.isImagePickerPresented = false
            // PHAsset과 함께 메타데이터 추출은 FilterCreateStore에서 처리
            
        case .setFilteredImage(let image):
            state.filteredImage = image
            
        case .startExtractingMetadata:
            state.isExtractingMetadata = true
            
        case .setPhotoMetadata(let metadata):
            state.photoMetadata = metadata
            state.isExtractingMetadata = false
            
        case .metadataExtractionFailed:
            print("❌ 메타데이터 추출 실패")
            state.isExtractingMetadata = false
            state.errorMessage = "이미지 메타데이터를 추출할 수 없습니다."
            
        case .updateFilterDescription(let description):
            state.filterDescription = description
            
        case .updatePrice(let price):
            state.price = price
            
        case .saveFilter:
            guard state.isValid else { return }
            state.isLoading = true
            // TODO: 필터 저장 로직 구현
            
        case .clearError:
            state.errorMessage = nil
        }
    }
} 