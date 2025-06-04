//
//  ImageFilterManager.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageFilterManager {
    private let context = CIContext()
    
    // MARK: - Public Methods
    
    /// 모든 필터를 적용하여 이미지를 처리합니다
    func applyFilters(
        to image: UIImage,
        brightness: Float = 0.0,
        exposure: Float = 0.0,
        contrast: Float = 0.0,
        saturation: Float = 0.0,
        sharpness: Float = 0.0,
        blur: Float = 0.0,
        vignette: Float = 0.0,
        noiseReduction: Float = 0.0,
        highlights: Float = 0.0,
        shadows: Float = 0.0,
        temperature: Float = 2000,
        blackPoint: Float = 0.0
    ) -> UIImage? {
        
        guard let ciImage = CIImage(image: image) else { return nil }
        var filteredImage = ciImage
        
        // 1. Brightness (자연스러운 노출 방식)
        if brightness != 0.0 {
            filteredImage = applyBrightness(to: filteredImage, brightness: brightness)
        }
        
        // 2. Color Controls (contrast, saturation만)
        if contrast != 0.0 || saturation != 0.0 {
            filteredImage = applyColorControls(
                to: filteredImage,
                contrast: contrast + 1.0, // CIColorControls에서 1.0이 기본값
                saturation: saturation + 1.0
            )
        }
        
        // 3. Exposure
        if exposure != 0.0 {
            filteredImage = applyExposure(to: filteredImage, exposure: exposure)
        }
        
        // 4. Sharpness
        if sharpness != 0.0 {
            filteredImage = applySharpness(to: filteredImage, sharpness: sharpness)
        }
        
        // 5. Blur
        if blur > 0.0 {
            filteredImage = applyGaussianBlur(to: filteredImage, radius: blur * 10) // 0-10 범위로 스케일링
        }
        
        // 6. Vignette
        if vignette != 0.0 {
            filteredImage = applyVignette(to: filteredImage, intensity: vignette)
        }
        
        // 7. Noise Reduction
        if noiseReduction > 0.0 {
            filteredImage = applyNoiseReduction(to: filteredImage, level: noiseReduction)
        }
        
        // 8. Highlights and Shadows
        if highlights != 0.0 || shadows != 0.0 {
            filteredImage = applyHighlightShadow(
                to: filteredImage,
                highlightAmount: highlights,
                shadowAmount: shadows
            )
        }
        
        // 9. Temperature
        if temperature != 6000 {
            filteredImage = applyTemperature(to: filteredImage, temperature: temperature)
        }
        
        // 10. Black Point (Levels 조정)
        if blackPoint != 0.0 {
            filteredImage = applyLevels(to: filteredImage, blackPoint: blackPoint)
        }
        
        // CIImage를 UIImage로 변환
        guard let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Private Filter Methods
    
    private func applyColorControls(to image: CIImage, contrast: Float, saturation: Float) -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = image
        filter.contrast = contrast
        filter.saturation = saturation
        return filter.outputImage ?? image
    }
    
    private func applyExposure(to image: CIImage, exposure: Float) -> CIImage {
        let filter = CIFilter.exposureAdjust()
        filter.inputImage = image
        filter.ev = exposure * 2.0 // -2.0 ~ 2.0 범위로 스케일링
        return filter.outputImage ?? image
    }
    
    private func applySharpness(to image: CIImage, sharpness: Float) -> CIImage {
        let filter = CIFilter.sharpenLuminance()
        filter.inputImage = image
        filter.sharpness = abs(sharpness) * 2.0 // 0 ~ 2.0 범위
        return filter.outputImage ?? image
    }
    
    private func applyGaussianBlur(to image: CIImage, radius: Float) -> CIImage {
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = image
        filter.radius = radius
        return filter.outputImage ?? image
    }
    
    private func applyVignette(to image: CIImage, intensity: Float) -> CIImage {
        let filter = CIFilter.vignette()
        filter.inputImage = image
        filter.intensity = abs(intensity) * 2.0 // 0 ~ 2.0 범위
        filter.radius = 1.0
        return filter.outputImage ?? image
    }
    
    private func applyNoiseReduction(to image: CIImage, level: Float) -> CIImage {
        let filter = CIFilter.noiseReduction()
        filter.inputImage = image
        filter.noiseLevel = level * 0.1 // 0 ~ 0.1 범위
        filter.sharpness = 0.4
        return filter.outputImage ?? image
    }
    
    private func applyHighlightShadow(to image: CIImage, highlightAmount: Float, shadowAmount: Float) -> CIImage {
        let filter = CIFilter.highlightShadowAdjust()
        filter.inputImage = image
        filter.highlightAmount = highlightAmount
        filter.shadowAmount = shadowAmount
        return filter.outputImage ?? image
    }
    
    private func applyTemperature(to image: CIImage, temperature: Float) -> CIImage {
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = image
        // 2000K(-2000) ~ 10000K(+2000) 범위를 -2000 ~ +2000으로 매핑
        let neutralTemp = (temperature - 6000) * (2000 / 4000)
        filter.neutral = CIVector(x: CGFloat(neutralTemp), y: 0)
        filter.targetNeutral = CIVector(x: 6500, y: 0) // 기본 중성값
        return filter.outputImage ?? image
    }
    
    private func applyLevels(to image: CIImage, blackPoint: Float) -> CIImage {
        let filter = CIFilter.gammaAdjust()
        filter.inputImage = image
        // blackPoint를 gamma 값으로 변환 (0.5 ~ 1.5 범위)
        filter.power = 1.0 + (blackPoint * 0.5)
        return filter.outputImage ?? image
    }
    
    private func applyBrightness(to image: CIImage, brightness: Float) -> CIImage {
        let filter = CIFilter.exposureAdjust()
        filter.inputImage = image
        filter.ev = brightness
        return filter.outputImage ?? image
    }
} 