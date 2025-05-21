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
    
    var body: some View {
        let cardWidth = UIScreen.main.bounds.width * 0.65
        let spacing: CGFloat = 16
        let filters = store.state.hotTrendFilters
        
        VStack(alignment: .leading, spacing: 12) {
            Text("핫 트렌드")
                .fontStyle(.body1)
                .foregroundColor(.gray60)
                .padding(.leading, 16)
            
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
                            cardWidth: cardWidth
                        )
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
        .onAppear {
            store.dispatch(.fetchHotTrendFilters)
        }
    }
}
