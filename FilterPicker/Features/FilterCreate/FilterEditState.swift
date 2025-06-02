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
        }
    }
}

// MARK: - FilterEditState
struct FilterEditState {
    var originalImage: UIImage?
    var editedImage: UIImage?
    var selectedParameter: FilterParameter = .saturation
    
    // 필터 파라미터 값들 (-100 ~ 100 범위)
    var brightness: Float = 0.0
    var exposure: Float = 0.0
    var contrast: Float = 0.0
    var saturation: Float = 3.4  // 시안에서 보이는 초기값
    var sharpness: Float = 0.0
    
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
        }
    }
} 