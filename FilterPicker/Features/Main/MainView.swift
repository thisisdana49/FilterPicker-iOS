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
    @EnvironmentObject var scrollManager: ScrollResetManager
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 32) {
                    ZStack {
                        TodayFilterSectionView(store: store)
                        
                        FilterCategorySectionView()
                            .padding(.top, 463)
                    }
                    .padding(0)
                    
                    TrendingBannerSectionView()
                    TrendingFilterSectionscaleAspectFillView(store: store)
                    TodayCreatorSectionView(store: store)
                }
                .id("top")  // VStack 전체를 앵커로 사용
                .padding(.bottom, 20)  // 하단 패딩만 유지
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
            .onChange(of: scrollManager.scrollToTopTrigger) { _ in
                // ScrollResetManager 트리거가 변경되면 맨 위로 스크롤
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo("top", anchor: .top)
                }
                print("📜 [MainView] 탭 재선택으로 스크롤 맨 위로 이동")
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
