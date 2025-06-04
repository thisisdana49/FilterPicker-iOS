//
//  FilterEditStore.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI
import Combine

class FilterEditStore: ObservableObject {
    @Published var state = FilterEditState()
    
    private let reducer = FilterEditReducer()
    private let filterManager = ImageFilterManager()
    
    init(image: UIImage? = nil) {
        if let image = image {
            self.state.originalImage = image
            self.state.editedImage = image
        }
    }
    
    func send(_ intent: FilterEditIntent) {
        reducer.reduce(state: &state, intent: intent)
        
        // 파라미터 값 변경 시 실시간 필터 적용
        switch intent {
        case .updateParameterValue(_), .resetAllValues, .undo, .redo:
            applyFiltersToImage()
        default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    private func applyFiltersToImage() {
        guard let originalImage = state.originalImage else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let filteredImage = self.filterManager.applyFilters(
                to: originalImage,
                brightness: self.state.brightness,
                exposure: self.state.exposure,
                contrast: self.state.contrast,
                saturation: self.state.saturation,
                sharpness: self.state.sharpness,
                blur: self.state.blur,
                vignette: self.state.vignette,
                noiseReduction: self.state.noiseReduction,
                highlights: self.state.highlights,
                shadows: self.state.shadows,
                temperature: self.state.temperature,
                blackPoint: self.state.blackPoint
            )
            
            DispatchQueue.main.async {
                self.state.editedImage = filteredImage
            }
        }
    }
} 