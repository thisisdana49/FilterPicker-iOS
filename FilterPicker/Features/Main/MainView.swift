//
//  MainView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//


import SwiftUI

struct MainView: View {
    @StateObject private var store = MainStore()
    @State private var isRefreshing = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                ZStack {
                    TodayFilterSectionView(store: store)
                    
                    FilterCategorySectionView()
                        .padding(.top, 463)
                }
                .padding(0)
                
                TrendingBannerSectionView()
                TrendingFilterSectionView(store: store)
                TodayCreatorSectionView(store: store)
            }
            .padding(.vertical, 20)
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .global).minY
                    )
                }
            )
        }
        .background(Color.black)
        .ignoresSafeArea()
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
            if value > 100 && !isRefreshing {
                isRefreshing = true
                Task {
                    store.dispatch(.fetchTodayFilter)
                    store.dispatch(.fetchHotTrendFilters)
                    store.dispatch(.fetchTodayAuthor)
                    
                    // 새로고침 완료 후 상태 초기화
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isRefreshing = false
                    }
                }
            }
        }
    }
}

// MARK: - ScrollOffsetPreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
