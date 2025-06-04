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
            
        case .updateParameterValue(let displayValue):
            // 스냅샷은 startEditingParameter에서만 저장
            
            // 표시 값을 실제 값으로 변환
            let actualValue = state.displayToActual(displayValue, for: state.selectedParameter)
            
            switch state.selectedParameter {
            case .brightness:
                state.brightness = actualValue
            case .exposure:
                state.exposure = actualValue
            case .contrast:
                state.contrast = actualValue
            case .saturation:
                state.saturation = actualValue
            case .sharpness:
                state.sharpness = actualValue
            case .blur:
                state.blur = actualValue
            case .vignette:
                state.vignette = actualValue
            case .noiseReduction:
                state.noiseReduction = actualValue
            case .highlights:
                state.highlights = actualValue
            case .shadows:
                state.shadows = actualValue
            case .temperature:
                state.temperature = actualValue
            case .blackPoint:
                state.blackPoint = actualValue
            }
            // 실시간 필터 적용은 FilterEditStore에서 처리
            
        case .startEditingParameter:
            // 슬라이더 편집 시작 시 현재 상태를 스냅샷으로 저장
            state.saveCurrentSnapshot()
            
        case .resetAllValues:
            // 현재 상태를 스냅샷으로 저장 (리셋 전)
            state.saveCurrentSnapshot()
            
            state.brightness = 0.0         // -1.0 ~ 1.0, 슬라이더: 0
            state.exposure = 0.0           // -1.0 ~ 1.0, 슬라이더: 0
            state.contrast = 0.0           // 0.0 ~ 2.0, 슬라이더: 0
            state.saturation = 0.0         // 0.0 ~ 2.0, 슬라이더: 0
            state.sharpness = 0.0          // -1.0 ~ 1.0, 슬라이더: 0
            state.blur = 0.0               // -1.0 ~ 1.0, 슬라이더: 0
            state.vignette = 0.0           // -1.0 ~ 1.0, 슬라이더: 0
            state.noiseReduction = 0.0     // -1.0 ~ 1.0, 슬라이더: 0
            state.highlights = 0.0         // -1.0 ~ 1.0, 슬라이더: 0
            state.shadows = 0.0            // -1.0 ~ 1.0, 슬라이더: 0
            state.temperature = 2000       // 2000 ~ 10000, 슬라이더: 0
            state.blackPoint = 0.0         // -1.0 ~ 1.0, 슬라이더: 0
            state.editedImage = state.originalImage
            
        case .applyFilter:
            state.isLoading = true
            // TODO: 필터 적용 로직 구현
            
        case .saveChanges:
            state.isLoading = true
            // TODO: 변경사항 저장 로직 구현
            
        case .clearError:
            state.errorMessage = nil
            
        case .startComparing:
            state.isComparing = true
            
        case .stopComparing:
            state.isComparing = false
            
        case .undo:
            guard let lastSnapshot = state.undoStack.popLast() else { return }
            // 현재 상태를 redo 스택에 저장
            let currentSnapshot = FilterParameterSnapshot(from: state)
            state.redoStack.append(currentSnapshot)
            // 이전 상태로 복원
            state.applySnapshot(lastSnapshot)
            
        case .redo:
            guard let nextSnapshot = state.redoStack.popLast() else { return }
            // 현재 상태를 undo 스택에 저장
            let currentSnapshot = FilterParameterSnapshot(from: state)
            state.undoStack.append(currentSnapshot)
            // 다음 상태로 복원
            state.applySnapshot(nextSnapshot)
        }
    }
} 