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
    var filterParameters: FilterParameters? = nil        // 편집된 필터 파라미터 값들
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

// MARK: - FilterParameters
struct FilterParameters {
    let brightness: Float
    let exposure: Float
    let contrast: Float
    let saturation: Float
    let sharpness: Float
    let blur: Float
    let vignette: Float
    let noiseReduction: Float
    let highlights: Float
    let shadows: Float
    let temperature: Float
    let blackPoint: Float
    
    // FilterEditState에서 변환
    init(from editState: FilterEditState) {
        self.brightness = editState.brightness
        self.exposure = editState.exposure
        self.contrast = editState.contrast
        self.saturation = editState.saturation
        self.sharpness = editState.sharpness
        self.blur = editState.blur
        self.vignette = editState.vignette
        self.noiseReduction = editState.noiseReduction
        self.highlights = editState.highlights
        self.shadows = editState.shadows
        self.temperature = editState.temperature
        self.blackPoint = editState.blackPoint
    }
    
    // FilterValues로 변환
    func toFilterValues() -> FilterValues {
        return FilterValues(
            brightness: brightness,
            exposure: exposure,
            contrast: contrast,
            saturation: saturation,
            sharpness: sharpness,
            blur: blur,
            vignette: vignette,
            noiseReduction: noiseReduction,
            highlights: highlights,
            shadows: shadows,
            temperature: temperature,
            blackPoint: blackPoint
        )
    }
} 