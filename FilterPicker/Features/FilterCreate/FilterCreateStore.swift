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
                guard let self = self, let metadata = metadata else {
                    print("❌ PHAsset에서 메타데이터 추출 실패")
                    self?.send(.metadataExtractionFailed)
                    return
                }
                
                self.logMetadata(metadata)
                self.send(.setPhotoMetadata(metadata))
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
            return
        }
        
        print("📤 필터 업로드 처리 시작...")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
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
                DispatchQueue.main.async {
                    print("❌ 이미지 압축 실패 - 512KB 이하로 압축할 수 없음")
                    // TODO: 에러 처리
                }
                return
            }
            
            // 업로드 요청 데이터 생성
            let uploadRequest = self.createUploadRequest(uploadData: uploadData)
            
            DispatchQueue.main.async {
                print("✅ 업로드 데이터 준비 완료")
                print("  - 총 크기: \(String(format: "%.1f", uploadData.totalSizeKB))KB")
                print("  - 원본 이미지: \(uploadData.originalImageData.count) bytes")
                print("  - 필터 이미지: \(uploadData.filteredImageData.count) bytes")
                
                // TODO: 실제 서버 업로드 구현
                self.uploadToServer(request: uploadRequest)
            }
        }
    }
    
    private func createUploadRequest(uploadData: UploadImageData) -> FilterUploadRequest {
        let originalBase64 = uploadData.originalImageData.base64EncodedString()
        let filteredBase64 = uploadData.filteredImageData.base64EncodedString()
        
        return FilterUploadRequest(
            name: state.filterName,
            description: state.filterDescription,
            category: state.selectedCategory?.rawValue ?? "portrait",
            price: Int(state.price) ?? 0,
            originalImage: originalBase64,
            filteredImage: filteredBase64,
            metadata: uploadData.metadata
        )
    }
    
    private func uploadToServer(request: FilterUploadRequest) {
        // TODO: 실제 네트워크 요청 구현
        print("🚀 서버 업로드 시뮬레이션")
        print("  - 필터명: \(request.name)")
        print("  - 카테고리: \(request.category)")
        print("  - 가격: \(request.price)원")
        print("  - 원본 이미지 크기: \(request.originalImage.count) chars")
        print("  - 필터 이미지 크기: \(request.filteredImage.count) chars")
        
        // 성공 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.state.isLoading = false
            print("✅ 필터 업로드 완료!")
            // TODO: 성공 처리 및 화면 이동
        }
    }
} 