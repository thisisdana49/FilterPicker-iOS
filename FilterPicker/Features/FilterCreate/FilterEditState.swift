//
//  FilterEditState.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

// MARK: - FilterParameterSnapshot
struct FilterParameterSnapshot {
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
    
    init(from state: FilterEditState) {
        self.brightness = state.brightness
        self.exposure = state.exposure
        self.contrast = state.contrast
        self.saturation = state.saturation
        self.sharpness = state.sharpness
        self.blur = state.blur
        self.vignette = state.vignette
        self.noiseReduction = state.noiseReduction
        self.highlights = state.highlights
        self.shadows = state.shadows
        self.temperature = state.temperature
        self.blackPoint = state.blackPoint
    }
}

// MARK: - FilterParameter
enum FilterParameter: String, CaseIterable {
    case brightness = "BRIGHTNESS"
    case exposure = "EXPOSURE"
    case contrast = "CONTRAST"
    case saturation = "SATURATION"
    case sharpness = "SHARPNESS"
    case blur = "BLUR"
    case vignette = "VIGNETTE"
    case noiseReduction = "NOISE REDUCTION"
    case highlights = "HIGHLIGHTS"
    case shadows = "SHADOWS"
    case temperature = "TEMPERATURE"
    case blackPoint = "BLACK POINT"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .brightness: return "sun.max"
        case .exposure: return "camera.aperture"
        case .contrast: return "circle.lefthalf.filled"
        case .saturation: return "drop.fill"
        case .sharpness: return "triangle"
        case .blur: return "aqi.medium"
        case .vignette: return "circle.dashed"
        case .noiseReduction: return "waveform"
        case .highlights: return "sun.max.fill"
        case .shadows: return "moon.fill"
        case .temperature: return "thermometer"
        case .blackPoint: return "circle.fill"
        }
    }
}

// MARK: - FilterEditState
struct FilterEditState {
    var originalImage: UIImage?
    var editedImage: UIImage?
    var selectedParameter: FilterParameter = .brightness
    
    // 필터 파라미터 값들 (API에 보낼 실제 값)
    var brightness: Float = 0.0        // -1.0 ~ 1.0, 슬라이더: 0
    var exposure: Float = 0.0          // -1.0 ~ 1.0, 슬라이더: 0
    var contrast: Float = 0.0          // 0.0 ~ 2.0, 슬라이더: 0
    var saturation: Float = 0.0        // 0.0 ~ 2.0, 슬라이더: 0
    var sharpness: Float = 0.0         // -1.0 ~ 1.0, 슬라이더: 0
    var blur: Float = 0.0              // -1.0 ~ 1.0, 슬라이더: 0
    var vignette: Float = 0.0          // -1.0 ~ 1.0, 슬라이더: 0
    var noiseReduction: Float = 0.0    // -1.0 ~ 1.0, 슬라이더: 0
    var highlights: Float = 0.0        // -1.0 ~ 1.0, 슬라이더: 0
    var shadows: Float = 0.0           // -1.0 ~ 1.0, 슬라이더: 0
    var temperature: Float = 2000      // 2000 ~ 10000, 슬라이더: 0
    var blackPoint: Float = 0.0        // -1.0 ~ 1.0, 슬라이더: 0
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // MARK: - Compare Mode
    var isComparing: Bool = false  // 원본과 편집본 비교 모드
    
    // MARK: - Undo/Redo History
    var undoStack: [FilterParameterSnapshot] = []
    var redoStack: [FilterParameterSnapshot] = []
    
    // Undo/Redo 가능 여부
    var canUndo: Bool {
        return !undoStack.isEmpty
    }
    
    var canRedo: Bool {
        return !redoStack.isEmpty
    }
    
    // 현재 상태를 스냅샷으로 저장
    mutating func saveCurrentSnapshot() {
        let snapshot = FilterParameterSnapshot(from: self)
        undoStack.append(snapshot)
        // Redo 스택은 새로운 액션 시 클리어
        redoStack.removeAll()
    }
    
    // 스냅샷을 현재 상태에 적용
    mutating func applySnapshot(_ snapshot: FilterParameterSnapshot) {
        self.brightness = snapshot.brightness
        self.exposure = snapshot.exposure
        self.contrast = snapshot.contrast
        self.saturation = snapshot.saturation
        self.sharpness = snapshot.sharpness
        self.blur = snapshot.blur
        self.vignette = snapshot.vignette
        self.noiseReduction = snapshot.noiseReduction
        self.highlights = snapshot.highlights
        self.shadows = snapshot.shadows
        self.temperature = snapshot.temperature
        self.blackPoint = snapshot.blackPoint
    }
    
    // 현재 선택된 파라미터의 실제 값 (API 값)
    var currentParameterActualValue: Float {
        switch selectedParameter {
        case .brightness: return brightness
        case .exposure: return exposure
        case .contrast: return contrast
        case .saturation: return saturation
        case .sharpness: return sharpness
        case .blur: return blur
        case .vignette: return vignette
        case .noiseReduction: return noiseReduction
        case .highlights: return highlights
        case .shadows: return shadows
        case .temperature: return temperature
        case .blackPoint: return blackPoint
        }
    }
    
    // 현재 선택된 파라미터의 표시 값 (사용자 슬라이더 값)
    var currentParameterDisplayValue: Float {
        return actualToDisplay(currentParameterActualValue, for: selectedParameter)
    }
    
    // 실제 값 → 표시 값 변환
    func actualToDisplay(_ actualValue: Float, for parameter: FilterParameter) -> Float {
        switch parameter {
        case .brightness, .exposure, .sharpness, .blur, .vignette, .noiseReduction, .highlights, .shadows, .blackPoint:
            // -1.0 ~ 1.0 → -100 ~ 100
            return actualValue * 100
        case .contrast, .saturation:
            // 0.0 ~ 2.0 → 0 ~ 100
            return actualValue * 50
        case .temperature:
            // 2000 ~ 10000 → 0 ~ 100
            return (actualValue - 2000) / (10000 - 2000) * 100
        }
    }
    
    // 표시 값 → 실제 값 변환
    func displayToActual(_ displayValue: Float, for parameter: FilterParameter) -> Float {
        switch parameter {
        case .brightness, .exposure, .sharpness, .blur, .vignette, .noiseReduction, .highlights, .shadows, .blackPoint:
            // -100 ~ 100 → -1.0 ~ 1.0
            return displayValue / 100
        case .contrast, .saturation:
            // 0 ~ 100 → 0.0 ~ 2.0
            return displayValue / 50
        case .temperature:
            // 0 ~ 100 → 2000 ~ 10000
            return (displayValue / 100) * (10000 - 2000) + 2000
        }
    }
} 