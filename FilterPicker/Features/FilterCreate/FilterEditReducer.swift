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
            }
            // TODO: 실시간 필터 적용 로직 추가
            
        case .resetAllValues:
            state.brightness = 0.0
            state.exposure = 0.0
            state.contrast = 0.0
            state.saturation = 0.0
            state.sharpness = 0.0
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