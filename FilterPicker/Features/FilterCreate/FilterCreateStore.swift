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
} 