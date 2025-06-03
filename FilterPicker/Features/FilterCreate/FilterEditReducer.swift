//
//  FilterEditReducer.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

struct FilterEditReducer {
    func reduce(state: inout FilterEditState, intent: FilterEditIntent) {
        switch intent {
        case .setImage(let image):
            state.originalImage = image
            state.editedImage = image
            
        case .selectParameter(let parameter):
            state.selectedParameter = parameter
            
        case .updateParameterValue(let value):
            switch state.selectedParameter {
            case .brightness:
                state.brightness = value
            case .exposure:
                state.exposure = value
            case .contrast:
                state.contrast = value
            case .saturation:
                state.saturation = value
            case .sharpness:
                state.sharpness = value
            case .blur:
                state.blur = value
            case .vignette:
                state.vignette = value
            case .noiseReduction:
                state.noiseReduction = value
            case .highlights:
                state.highlights = value
            case .shadows:
                state.shadows = value
            case .temperature:
                state.temperature = value
            case .blackPoint:
                state.blackPoint = value
            }
            // TODO: 실시간 필터 적용 로직 추가
            
        case .resetAllValues:
            state.brightness = 0.15
            state.exposure = 0.3
            state.contrast = 1.05
            state.saturation = 1.1
            state.sharpness = 0.5
            state.blur = 0.0
            state.vignette = 0.2
            state.noiseReduction = 0.1
            state.highlights = -0.1
            state.shadows = 0.15
            state.temperature = 5800
            state.blackPoint = 0.03
            state.editedImage = state.originalImage
            
        case .applyFilter:
            state.isLoading = true
            // TODO: 필터 적용 로직 구현
            
        case .saveChanges:
            state.isLoading = true
            // TODO: 변경사항 저장 로직 구현
            
        case .clearError:
            state.errorMessage = nil
        }
    }
} 