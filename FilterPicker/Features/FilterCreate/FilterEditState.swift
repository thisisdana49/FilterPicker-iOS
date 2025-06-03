//
//  FilterEditState.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

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
    var selectedParameter: FilterParameter = .saturation
    
    // 필터 파라미터 값들
    var brightness: Float = 0.15
    var exposure: Float = 0.3
    var contrast: Float = 1.05
    var saturation: Float = 1.1
    var sharpness: Float = 0.5
    var blur: Float = 0.0
    var vignette: Float = 0.2
    var noiseReduction: Float = 0.1
    var highlights: Float = -0.1
    var shadows: Float = 0.15
    var temperature: Float = 5800
    var blackPoint: Float = 0.03
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    // 현재 선택된 파라미터의 값
    var currentParameterValue: Float {
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
} 