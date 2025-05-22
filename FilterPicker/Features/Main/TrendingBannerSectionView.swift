//
//  TrendingBannerSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct TrendingBanner: Identifiable {
    let id: Int
    let color: Color
}

private let mockBanners: [TrendingBanner] = (0..<12).map {
    TrendingBanner(id: $0, color: Color(hue: Double($0)/12, saturation: 0.6, brightness: 0.8))
}

struct TrendingBannerSectionView: View {
    let banners: [TrendingBanner] = mockBanners
    @State private var currentIndex: Int = 0

    var body: some View {
        let bannerWidth = UIScreen.main.bounds.width - 40
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 32)
                .fill(banners[currentIndex].color)
                .frame(width: bannerWidth, height: 120)
                .animation(.easeInOut, value: currentIndex)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -30 {
                                withAnimation { currentIndex = (currentIndex + 1) % banners.count }
                            } else if value.translation.width > 30 {
                                withAnimation { currentIndex = (currentIndex - 1 + banners.count) % banners.count }
                            }
                        }
                )

            Text("\(currentIndex+1)/\(banners.count)")
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
                .padding(8)
        }
        .padding(.horizontal, 20)
    }
}
