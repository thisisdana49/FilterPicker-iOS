//
//  FilterDetailView.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import SwiftUI
import MapKit

struct FilterDetailView: View {
    let filterId: String
    @StateObject private var store = FilterDetailStore()
    @State private var dragPosition: CGFloat = 0.5 // 드래그 위치 (0.0 ~ 1.0)
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarVisibility: TabBarVisibilityManager
    
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
                                        URLImageView(url: beforeURL, showOverlay: false, contentMode: .fill)
                                            .frame(width: geometry.size.width, height: geometry.size.width * 4/3)
                                            .clipped()
                                    }
                                    
                                    // After 이미지 (왼쪽, 마스킹 적용)
                                    if let afterURL = URL(string: filterDetail.filteredImageURL) {
                                        URLImageView(url: afterURL, showOverlay: false, contentMode: .fill)
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
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            // 지도 영역
                                            let coordinate = CLLocationCoordinate2D(
                                                latitude: filterDetail.photoMetadata.latitude ?? 0.0,
                                                longitude: filterDetail.photoMetadata.longitude ?? 0.0
                                            )
                                            let region = MKCoordinateRegion(
                                                center: coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                            )
                                            
                                            Map(coordinateRegion: .constant(region))
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(8)
                                            .disabled(true) // 지도 인터랙션 비활성화
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                // 기기 정보
                                                HStack {
                                                    Text(filterDetail.photoMetadata.camera ?? "Unknown Camera")
                                                        .font(.system(size: 16, weight: .medium))
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                    Text(filterDetail.photoMetadata.format)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                // 카메라 상세 정보
                                                let lensInfo = filterDetail.photoMetadata.lensInfo ?? "Unknown Lens"
                                                let focalLength = filterDetail.photoMetadata.focalLength ?? 0
                                                let aperture = filterDetail.photoMetadata.aperture ?? 0
                                                let iso = filterDetail.photoMetadata.iso ?? 0
                                                
                                                Text("\(lensInfo) - \(String(format: "%.0f", focalLength)) mm f/\(String(format: "%.1f", aperture)) ISO \(iso)")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                                    .lineLimit(2)
                                                
                                                // 해상도 및 파일 정보
                                                let megaPixels = formatMegaPixels(width: filterDetail.photoMetadata.pixelWidth, height: filterDetail.photoMetadata.pixelHeight)
                                                let dimensions = "\(filterDetail.photoMetadata.pixelWidth) x \(filterDetail.photoMetadata.pixelHeight)"
                                                let fileSize = formatFileSize(filterDetail.photoMetadata.fileSize)
                                                
                                                Text("\(megaPixels) • \(dimensions) • \(fileSize)")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(2)
                                                
                                                // 위치 정보 (임시)
                                                if store.state.isLoadingAddress {
                                                    HStack {
                                                        ProgressView()
                                                            .scaleEffect(0.8)
                                                        Text("주소 조회 중...")
                                                    }
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                                } else if let addressInfo = store.state.addressInfo {
                                                    Text(addressInfo.displayAddress)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.gray)
                                                        .lineLimit(1)
                                                } else if store.state.addressError != nil {
                                                    Text("주소를 찾을 수 없습니다")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.gray)
                                                        .lineLimit(1)
                                                } else {
                                                    let latitude = filterDetail.photoMetadata.latitude ?? 0
                                                    let longitude = filterDetail.photoMetadata.longitude ?? 0
                                                    Text("좌표: \(String(format: "%.4f", latitude)), \(String(format: "%.4f", longitude))")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.gray)
                                                        .lineLimit(1)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.15))
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
                                            URLImageView(url: url, showOverlay: false, contentMode: .fill)
                                                .frame(width: 48, height: 48)
                                                .clipped()
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
                                        .padding(.bottom, 68)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, geometry.safeAreaInsets.bottom + 68)
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
            tabBarVisibility.hideTabBar()
            print("🔒 [FilterDetailView] 탭바 숨김")
        }
        .onDisappear {
            tabBarVisibility.showTabBar()
            print("🔓 [FilterDetailView] 탭바 표시")
        }
        .onChange(of: store.state.filterDetail) { filterDetail in
            // 필터 상세 로딩 완료 후 주소 로딩
            if let photoMetadata = filterDetail?.photoMetadata,
               let latitude = photoMetadata.latitude,
               let longitude = photoMetadata.longitude {
                store.dispatch(.loadAddress(latitude: latitude, longitude: longitude))
            }
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
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let mb = Double(bytes) / 1024.0 / 1024.0
        return String(format: "%.1fMB", mb)
    }
    
    private func formatMegaPixels(width: Int, height: Int) -> String {
        let megapixels = Double(width * height) / 1_000_000.0
        return String(format: "%.1fMP", megapixels)
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
