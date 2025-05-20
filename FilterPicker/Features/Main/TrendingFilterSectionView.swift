//
//  TrendingFilterSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct TrendingFilter: Identifiable {
    let id: UUID = UUID()
    let imageName: String
    let name: String
    let likes: Int
    let isEnabled: Bool
}

private let mockTrendingFilters: [TrendingFilter] = [
    .init(imageName: "trend1", name: "소낙새", likes: 121, isEnabled: true),
    .init(imageName: "trend2", name: "화양연화", likes: 0, isEnabled: false),
    .init(imageName: "trend3", name: "블루카", likes: 30, isEnabled: true),
    .init(imageName: "trend4", name: "그린필름", likes: 45, isEnabled: true),
    .init(imageName: "trend5", name: "레트로", likes: 88, isEnabled: true),
    .init(imageName: "trend6", name: "모노", likes: 12, isEnabled: true),
    .init(imageName: "trend7", name: "오로라", likes: 67, isEnabled: true),
    .init(imageName: "trend8", name: "스윗핑크", likes: 53, isEnabled: true)
]

struct TrendingFilterSectionView: View {
    let filters: [TrendingFilter] = mockTrendingFilters
    @State private var dragOffset: CGFloat = 0
    @State private var currentIndex: Int = 0
    
    var body: some View {
        let cardWidth = UIScreen.main.bounds.width * 0.65
        let spacing: CGFloat = 16
        
        VStack(alignment: .leading, spacing: 12) {
            Text("핫 트렌드")
                .fontStyle(.body1)
                .foregroundColor(.gray60)
                .padding(.leading, 16)
            
            GeometryReader { geo in
                HStack(spacing: spacing) {
                    ForEach(Array(filters.enumerated()), id: \.element.id) { idx, filter in
                        let isCenter = idx == currentIndex
                        let distance = abs(CGFloat(idx) * (cardWidth + spacing) + dragOffset - CGFloat(currentIndex) * (cardWidth + spacing))
                        let scale = max(0.9, 1 - distance / geo.size.width * 0.2)
                        
                        ZStack(alignment: .topLeading) {
                            Image(filter.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: cardWidth, height: 220)
                                .clipped()
                                .cornerRadius(20)
                                .overlay(
                                    Color.black.opacity(isCenter ? 0 : 0.6)
                                        .animation(.easeInOut(duration: 0.3), value: isCenter)
                                )
                            Text(filter.name)
                                .fontStyle(.mulgyeolCaption1)
                                .foregroundColor(.gray30)
                                .padding([.top, .leading], 12)
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.white)
                                        Text("\(filter.likes)")
                                            .fontStyle(.caption1)
                                            .foregroundColor(.gray30)
                                    }
                                    .padding(8)
                                    .background(Color.black.opacity(0.4))
                                    .cornerRadius(8)
                                    .padding([.bottom, .trailing], 12)
                                }
                            }
                        }
                        .frame(width: cardWidth, height: 220)
                        .scaleEffect(scale)
                        .shadow(radius: isCenter ? 8 : 2)
                        .animation(.easeInOut(duration: 0.3), value: isCenter)
                    }
                }
                .offset(x: -CGFloat(currentIndex) * (cardWidth + spacing) + dragOffset + (geo.size.width - cardWidth) / 2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = cardWidth / 2
                            var newIndex = currentIndex
                            if value.predictedEndTranslation.width < -threshold {
                                newIndex = min(currentIndex + 1, filters.count - 1)
                            } else if value.predictedEndTranslation.width > threshold {
                                newIndex = max(currentIndex - 1, 0)
                            }
                            withAnimation(.easeInOut) {
                                currentIndex = newIndex
                                dragOffset = 0
                            }
                        }
                )
            }
            .frame(height: 240)
        }
    }
}

#Preview {
    TrendingFilterSectionView()
} 
