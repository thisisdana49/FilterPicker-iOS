//
//  TrendingFilterSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct TrendingFilterSectionView: View {
    @ObservedObject var store: MainStore
    @State private var dragOffset: CGFloat = 0
    @State private var currentIndex: Int = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        let cardWidth = UIScreen.main.bounds.width * (200.0 / 390.0)
        let cardHeight = cardWidth * (240.0 / 200.0)
        let spacing: CGFloat = 0
        let filters = store.state.updatedHotTrendFilters
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("핫 트렌드")
                    .multilineTextAlignment(.leading)
                    .fontStyle(.body1)
                    .foregroundColor(.gray60)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                GeometryReader { geo in
                    HStack(spacing: spacing) {
                        ForEach(filters.indices, id: \.self) { idx in
                            let filter = filters[idx]
                            let isCenter = idx == currentIndex
                            let distance = abs(CGFloat(idx) * (cardWidth + spacing) + dragOffset - CGFloat(currentIndex) * (cardWidth + spacing))
                            let scale = max(0.9, 1 - distance / geo.size.width * 0.2)
                            TrendingFilterCardView(
                                filter: filter,
                                isCenter: isCenter,
                                scale: scale,
                                cardWidth: cardWidth,
                                cardHeight: cardHeight,
                                isDragging: isDragging,
                                onLikeTapped: {
                                    store.dispatch(.toggleLike(filter.filterId))
                                }
                            )
                        }
                    }
                    .offset(x: -CGFloat(currentIndex) * (cardWidth + spacing) + dragOffset + (geo.size.width - cardWidth) / 2 + 4)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 15)
                            .onChanged { value in
                                // 세로 스크롤을 우선시: 세로 움직임이 가로보다 크면 제스처 무시
                                let horizontalDistance = abs(value.translation.width)
                                let verticalDistance = abs(value.translation.height)
                                
                                // 세로 움직임이 가로 움직임보다 1.2배 이상 크면 가로 제스처 무시
                                if verticalDistance > horizontalDistance * 1.2 {
                                    return
                                }
                                
                                // 가로 움직임이 더 클 때만 카드 스와이프 처리
                                if horizontalDistance > verticalDistance * 0.8 {
                                    isDragging = true
                                    dragOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                let horizontalDistance = abs(value.translation.width)
                                let verticalDistance = abs(value.translation.height)
                                
                                // 세로 움직임이 우세하면 카드 스와이프 무시
                                if verticalDistance > horizontalDistance * 1.2 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        dragOffset = 0
                                    }
                                    isDragging = false
                                    return
                                }
                                
                                let threshold: CGFloat = cardWidth / 4 // threshold 더 줄여서 민감도 증가
                                var newIndex = currentIndex
                                
                                if value.translation.width < -threshold && horizontalDistance > 30 {
                                    newIndex = min(currentIndex + 1, filters.count - 1)
                                } else if value.translation.width > threshold && horizontalDistance > 30 {
                                    newIndex = max(currentIndex - 1, 0)
                                }
                                
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentIndex = newIndex
                                    dragOffset = 0
                                }
                                
                                // 드래그 완료 후 약간의 지연 후 isDragging 해제
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isDragging = false
                                }
                            }
                    )
                }
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight)
                
                // 페이지 인디케이터
                if filters.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<filters.count, id: \.self) { index in
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(index == currentIndex ? .white : .white.opacity(0.3))
                                .animation(.easeInOut(duration: 0.2), value: currentIndex)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 0)
            .padding(.bottom, spacing)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            store.dispatch(.fetchHotTrendFilters)
        }
    }
}
