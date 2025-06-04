//
//  FilterCreateStore.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI
import Combine
import Photos

class FilterCreateStore: ObservableObject {
    @Published var state = FilterCreateState()
    
    private let reducer = FilterCreateReducer()
    private let metadataExtractor = PhotoMetadataExtractor()
    private let uploadService: FilterUploadService = DefaultFilterUploadService()
    
    func send(_ intent: FilterCreateIntent) {
        reducer.reduce(state: &state, intent: intent)
        
        // 이미지 선택 시 메타데이터 자동 추출
        if case .selectImage(let image, let phAsset) = intent {
            extractMetadata(from: image, phAsset: phAsset)
        }
        
        // 필터 저장 시 이미지 처리 및 업로드
        if case .saveFilter = intent {
            processAndUploadFilter()
        }
    }
    
    // MARK: - Private Methods
    
    private func extractMetadata(from image: UIImage, phAsset: PHAsset?) {
        // 메타데이터 추출 시작
        send(.startExtractingMetadata)
        print("📷 이미지 메타데이터 추출 시작...")
        
        if let phAsset = phAsset {
            // PHAsset이 있으면 더 정확한 메타데이터 추출
            print("📷 PHAsset을 사용하여 정확한 메타데이터 추출 중...")
            metadataExtractor.extractMetadata(from: phAsset) { [weak self] metadata in
                DispatchQueue.main.async {
                    guard let self = self, let metadata = metadata else {
                        print("❌ PHAsset에서 메타데이터 추출 실패")
                        self?.send(.metadataExtractionFailed)
                        return
                    }
                    
                    self.logMetadata(metadata)
                    self.send(.setPhotoMetadata(metadata))
                }
            }
        } else {
            // PHAsset이 없으면 UIImage에서 기본 메타데이터 추출
            print("📷 UIImage에서 기본 메타데이터 추출 중...")
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                let metadata = self.metadataExtractor.extractMetadata(from: image)
                
                DispatchQueue.main.async {
                    self.logMetadata(metadata)
                    self.send(.setPhotoMetadata(metadata))
                }
            }
        }
    }
    
    private func logMetadata(_ metadata: PhotoMetadata) {
        // 메타데이터 로그 출력
        print("📷 메타데이터 추출 완료:")
        print("  - 카메라: \(metadata.camera ?? "Unknown")")
        print("  - 렌즈 정보: \(metadata.lensInfo ?? "Unknown")")
        print("  - 초점거리: \(metadata.focalLength ?? 0)mm")
        print("  - 조리개: f/\(metadata.aperture ?? 0)")
        print("  - ISO: \(metadata.iso ?? 0)")
        print("  - 셔터 속도: \(metadata.shutterSpeed ?? "Unknown")")
        print("  - 해상도: \(metadata.pixelWidth) x \(metadata.pixelHeight)")
        print("  - 파일 크기: \(metadata.fileSize) bytes")
        print("  - 포맷: \(metadata.format)")
        print("  - 촬영 시간: \(metadata.dateTimeOriginal ?? "Unknown")")
        print("  - 위도: \(metadata.latitude ?? 0)")
        print("  - 경도: \(metadata.longitude ?? 0)")
        print("📷 ===================================")
    }
    
    private func processAndUploadFilter() {
        guard let originalImage = state.selectedImage,
              let metadata = state.photoMetadata else {
            print("❌ 필터 저장 실패: 이미지 또는 메타데이터 없음")
            state.isLoading = false
            state.errorMessage = "이미지 또는 메타데이터가 없습니다."
            return
        }
        
        print("📤 필터 업로드 처리 시작...")
        state.isLoading = true
        
        Task {
            do {
                // 필터가 적용된 이미지가 있으면 사용, 없으면 원본 사용  
                let filteredImage = self.state.filteredImage ?? originalImage
                
                if self.state.filteredImage != nil {
                    print("✅ 필터가 적용된 이미지 사용")
                } else {
                    print("⚠️ 필터 미적용 - 원본 이미지 사용")
                }
                
                // 이미지 압축 처리
                guard let uploadData = ImageProcessor.prepareForUpload(
                    originalImage: originalImage,
                    filteredImage: filteredImage,
                    metadata: metadata
                ) else {
                    await MainActor.run {
                        print("❌ 이미지 압축 실패 - 512KB 이하로 압축할 수 없음")
                        self.state.isLoading = false
                        self.state.errorMessage = "이미지 크기가 너무 큽니다. 다른 이미지를 선택해주세요."
                    }
                    return
                }
                
                // 필터 요청 데이터 생성
                let filterRequest = self.createFilterRequest(metadata: metadata)
                
                print("✅ 업로드 데이터 준비 완료")
                print("  - 총 크기: \(String(format: "%.1f", uploadData.totalSizeKB))KB")
                print("  - 원본 이미지: \(uploadData.originalImageData.count) bytes")
                print("  - 필터 이미지: \(uploadData.filteredImageData.count) bytes")
                
                // async/await 패턴으로 API 호출
                let response = try await uploadService.uploadFilter(
                    uploadData: uploadData,
                    filterInfo: filterRequest
                )
                
                await MainActor.run {
                    self.handleUploadSuccess(response)
                }
                
            } catch {
                await MainActor.run {
                    self.handleUploadError(error)
                }
            }
        }
    }
    
    private func createFilterRequest(metadata: PhotoMetadata) -> FilterCreateRequest {
        // 카테고리 이름을 한글로 매핑
        let categoryKorean = mapCategoryToKorean(state.selectedCategory)
        
        // 필터 파라미터 값 생성 (현재는 기본값, 추후 실제 필터 편집 값과 연동)
        let filterValues = createFilterValues()
        
        return FilterCreateRequest(
            category: categoryKorean,
            title: state.filterName,
            price: Int(state.price) ?? 0,
            description: state.filterDescription,
            files: [], // 1단계에서 채워짐
            photoMetadata: metadata,
            filterValues: filterValues
        )
    }
    
    private func mapCategoryToKorean(_ category: FilterCategory?) -> String {
        switch category {
        case .food: return "푸드"
        case .portrait: return "인물"
        case .landscape: return "풍경"
        case .night: return "야경"
        case .star: return "별"
        default: return "인물"
        }
    }
    
    private func createFilterValues() -> FilterValues {
        // 실제 편집된 필터 값이 있으면 사용, 없으면 기본값
        if let parameters = state.filterParameters {
            print("✅ 편집된 필터 파라미터 사용")
            return parameters.toFilterValues()
        } else {
            print("⚠️ 필터 파라미터 없음 - 기본값 사용")
            return FilterValues(
                brightness: 0.0,
                exposure: 0.0,
                contrast: 0.0,
                saturation: 0.0,
                sharpness: 0.0,
                blur: 0.0,
                vignette: 0.0,
                noiseReduction: 0.0,
                highlights: 0.0,
                shadows: 0.0,
                temperature: 6500,
                blackPoint: 0.0
            )
        }
    }
    
    private func handleUploadSuccess(_ response: FilterCreateResponse) {
        state.isLoading = false
        
        print("🎉 필터 업로드 성공!")
        print("  - 응답: \(response.message ?? "성공")")
        
        // 성공 시 화면 닫기나 성공 메시지 표시
        // TODO: 성공 후 액션 정의 (화면 닫기, 피드 화면으로 이동 등)
    }
    
    private func handleUploadError(_ error: Error) {
        state.isLoading = false
        
        print("❌ 필터 업로드 실패: \(error.localizedDescription)")
        state.errorMessage = error.localizedDescription
    }
} 