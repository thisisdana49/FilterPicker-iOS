//
//  FilterDetailView.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import SwiftUI

struct FilterDetailView: View {
    let filterId: String
    @StateObject private var store = FilterDetailStore()
    @State private var isShowingOriginal = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if store.state.isLoading {
                ProgressView("로딩 중...")
                    .foregroundColor(.white)
            } else if let error = store.state.error {
                VStack {
                    Text("오류가 발생했습니다")
                        .foregroundColor(.white)
                    Text(error.localizedDescription)
                        .foregroundColor(.gray)
                        .font(.caption)
                    Button("다시 시도") {
                        store.dispatch(.loadFilterDetail(filterId: filterId))
                    }
                    .foregroundColor(.blue)
                }
            } else if let filterDetail = store.state.filterDetail {
                ScrollView {
                    VStack(spacing: 0) {
                        // 메인 이미지 영역
                        ZStack {
                            // 이미지
                            let imageURL = isShowingOriginal ? filterDetail.originalImageURL : filterDetail.filteredImageURL
                            if let url = URL(string: imageURL) {
                                URLImageView(url: url, showOverlay: false)
                                    .aspectRatio(3/4, contentMode: .fill)
                                    .frame(maxHeight: 500)
                                    .clipped()
                            }
                            
                            // After/Before 토글 버튼
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 0) {
                                        Button(action: { isShowingOriginal = false }) {
                                            Text("After")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(isShowingOriginal ? .gray : .white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(isShowingOriginal ? Color.clear : Color.white.opacity(0.3))
                                                )
                                        }
                                        
                                        Button(action: { isShowingOriginal = true }) {
                                            Text("Before")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(isShowingOriginal ? .white : .gray)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(isShowingOriginal ? Color.white.opacity(0.3) : Color.clear)
                                                )
                                        }
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.black.opacity(0.6))
                                    )
                                    
                                    Spacer()
                                }
                                .padding(.bottom, 20)
                            }
                        }
                        
                        // 정보 영역
                        VStack(alignment: .leading, spacing: 20) {
                            // 가격 정보
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(formatPrice(filterDetail.price))")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Coin")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                
                                HStack(spacing: 32) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("다운로드")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        Text("\(formatCount(filterDetail.buyerCount))+")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("평가")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        Text("\(filterDetail.likeCount)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            // 디바이스 정보
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(filterDetail.photoMetadata.camera)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("EXIF")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                )
                            }
                            
                            // EXIF 정보
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "camera")
                                        .foregroundColor(.gray)
                                        .frame(width: 24, height: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(filterDetail.photoMetadata.lensInfo) - \(filterDetail.photoMetadata.focalLength) mm f/\(String(format: "%.1f", filterDetail.photoMetadata.aperture)) ISO \(filterDetail.photoMetadata.iso)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                        Text("\(filterDetail.photoMetadata.pixelWidth) × \(filterDetail.photoMetadata.pixelHeight) • \(formatFileSize(filterDetail.photoMetadata.fileSize))")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                )
                            }
                            
                            // 필터 프리셋
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Filter Presets")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("LUT")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                                    FilterPresetItem(icon: "brightness.6", value: String(format: "%.1f", filterDetail.filterValues.brightness))
                                    FilterPresetItem(icon: "square.and.arrow.up", value: String(format: "%.1f", filterDetail.filterValues.exposure))
                                    FilterPresetItem(icon: "circle.lefthalf.filled", value: String(format: "%.1f", filterDetail.filterValues.contrast))
                                    FilterPresetItem(icon: "paintbrush", value: String(format: "%.1f", filterDetail.filterValues.saturation))
                                    FilterPresetItem(icon: "triangle.fill", value: String(format: "%.1f", filterDetail.filterValues.sharpness))
                                    FilterPresetItem(icon: "grid", value: String(format: "%.1f", filterDetail.filterValues.vignette))
                                    FilterPresetItem(icon: "square", value: String(format: "%.1f", filterDetail.filterValues.shadows))
                                    FilterPresetItem(icon: "circle.dotted", value: String(format: "%.1f", filterDetail.filterValues.highlights))
                                    FilterPresetItem(icon: "circle.righthalf.filled", value: String(format: "%.1f", filterDetail.filterValues.temperature / 1000))
                                    FilterPresetItem(icon: "moon.fill", value: String(format: "%.1f", filterDetail.filterValues.blur))
                                    FilterPresetItem(icon: "thermometer", value: String(format: "%.1f", filterDetail.filterValues.blackPoint))
                                    FilterPresetItem(icon: "gearshape", value: String(format: "%.1f", filterDetail.filterValues.noiseReduction))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                            )
                            
                            // 구매 버튼
                            Button(action: {
                                // 구매 로직
                            }) {
                                Text("구매안료")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white)
                                    )
                            }
                            
                            // 크리에이터 정보
                            HStack(spacing: 12) {
                                // 프로필 이미지
                                if let profileImageURL = filterDetail.creator.profileImage,
                                   !profileImageURL.isEmpty,
                                   let url = URL(string: filterDetail.creator.profileImageURL) {
                                    URLImageView(url: url, showOverlay: false)
                                        .frame(width: 48, height: 48)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Text(String(filterDetail.creator.nick.prefix(1)))
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.white)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(filterDetail.creator.nick)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("SESAC YOON")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // 메시지 보내기
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.gray.opacity(0.3))
                                        )
                                }
                            }
                            
                            // 해시태그
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: 8) {
                                ForEach(filterDetail.creator.hashTags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.2))
                                        )
                                }
                            }
                            
                            // 설명
                            Text(filterDetail.description)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(store.state.filterDetail?.title ?? "")
        .navigationBarItems(
            trailing: Button(action: {
                store.dispatch(.toggleLike(filterId: filterId))
            }) {
                Image(systemName: store.state.filterDetail?.isLiked == true ? "heart.fill" : "heart")
                    .font(.system(size: 18))
                    .foregroundColor(store.state.filterDetail?.isLiked == true ? .red : .white)
            }
            .disabled(store.state.isLikeLoading)
        )
        .onAppear {
            store.dispatch(.loadFilterDetail(filterId: filterId))
        }
    }
    
    // MARK: - Helper Methods
    private func formatPrice(_ price: Int) -> String {
        if price >= 1000 {
            return "\(price / 1000),\(String(format: "%03d", price % 1000))"
        }
        return "\(price)"
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            return "\(count / 1000).\(count % 1000 / 100)k"
        }
        return "\(count)"
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let mb = Double(bytes) / 1024.0 / 1024.0
        return String(format: "%.1fMB", mb)
    }
}

struct FilterPresetItem: View {
    let icon: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
            
            Text(value)
                .font(.system(size: 10))
                .foregroundColor(.white)
        }
    }
} 
