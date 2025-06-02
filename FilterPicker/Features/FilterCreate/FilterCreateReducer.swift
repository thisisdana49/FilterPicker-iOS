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
            
        case .selectImage(let image):
            state.selectedImage = image
            state.isImagePickerPresented = false
            // TODO: 이미지 메타데이터 추출 로직 추가
            
        case .updateImageMetadata(let metadata):
            state.imageMetadata = metadata
            
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