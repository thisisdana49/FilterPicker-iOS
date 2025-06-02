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
    @State private var dragPosition: CGFloat = 0.5 // 드래그 위치 (0.0 ~ 1.0)
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea(.all) // 모든 SafeArea 무시
                
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
                    VStack(spacing: 0) {
                        // 커스텀 네비게이션바
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Back")
                                        .font(.system(size: 16))
                                }
                                .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Text(filterDetail.title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                store.dispatch(.toggleLike(filterId: filterId))
                            }) {
                                Image(systemName: store.state.filterDetail?.isLiked == true ? "heart.fill" : "heart")
                                    .font(.system(size: 18))
                                    .foregroundColor(store.state.filterDetail?.isLiked == true ? .red : .white)
                            }
                            .disabled(store.state.isLikeLoading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, geometry.safeAreaInsets.top + 8)
                        .padding(.bottom, 8)
                        .background(Color.black)
                        
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                // 메인 이미지 영역
                                ZStack {
                                    // Before 이미지 (오른쪽, 배경)
                                    if let beforeURL = URL(string: filterDetail.originalImageURL) {
                                        URLImageView(url: beforeURL, showOverlay: false)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width, height: geometry.size.width * 4/3)
                                            .clipped()
                                    }
                                    
                                    // After 이미지 (왼쪽, 마스킹 적용)
                                    if let afterURL = URL(string: filterDetail.filteredImageURL) {
                                        URLImageView(url: afterURL, showOverlay: false)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width, height: geometry.size.width * 4/3)
                                            .clipped()
                                            .mask(
                                                Rectangle()
                                                    .frame(width: geometry.size.width * dragPosition)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            )
                                    }
                                    
                                    // 드래그 라인
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 2)
                                        .frame(height: geometry.size.width * 4/3)
                                        .position(x: geometry.size.width * dragPosition, y: (geometry.size.width * 4/3) / 2)
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 0)
                                    
                                    // 드래그 핸들
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 20, height: 20)
                                        .position(x: geometry.size.width * dragPosition, y: (geometry.size.width * 4/3) / 2)
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 0)
                                    
                                    // After/Before 라벨
                                    VStack {
                                        HStack {
                                            Text("After")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.black.opacity(0.6))
                                                )
                                                .padding(.leading, 20)
                                            
                                            Spacer()
                                            
                                            Text("Before")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.black.opacity(0.6))
                                                )
                                                .padding(.trailing, 20)
                                        }
                                        .padding(.top, 20)
                                        
                                        Spacer()
                                    }
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newPosition = value.location.x / geometry.size.width
                                            dragPosition = max(0, min(1, newPosition))
                                        }
                                )
                                
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
                                    HStack {
                                        Text(filterDetail.photoMetadata.camera)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
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
                                    
                                    // EXIF 정보
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "camera")
                                            .foregroundColor(.gray)
                                            .frame(width: 24, height: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(filterDetail.photoMetadata.lensInfo) - \(filterDetail.photoMetadata.focalLength) mm f/\(String(format: "%.1f", filterDetail.photoMetadata.aperture)) ISO \(filterDetail.photoMetadata.iso)")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Text("\(filterDetail.photoMetadata.pixelWidth) × \(filterDetail.photoMetadata.pixelHeight) • \(formatFileSize(filterDetail.photoMetadata.fileSize))")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                                    
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
                                        
                                        let contentWidth = geometry.size.width - 72 // 좌우 패딩 40 + 프리셋 패딩 32
                                        let spacing: CGFloat = 16
                                        let itemWidth = max(20, (contentWidth - (spacing * 5)) / 6) // 최소 20, 6개 아이템
                                        
                                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(itemWidth)), count: 6), spacing: spacing) {
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
                                        Text("구매완료")
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
                                            Text("\(tag)")
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
                                .padding(.bottom, geometry.safeAreaInsets.bottom + 40)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.all)
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
