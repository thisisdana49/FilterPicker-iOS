//
//  FilterFeedView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct FilterFeedView: View {
    @StateObject private var store = FilterFeedStore.shared
    @State private var isCreateFilterPresented = false
    @EnvironmentObject var tabBarVisibility: TabBarVisibilityManager
    @EnvironmentObject var scrollManager: ScrollResetManager
    
    // MARK: - Prefetching State
    @State private var lastLoadedIndex = -1
    @State private var prefetchThreshold = 5 // 마지막 아이템에서 5개 전에 prefetch
    @State private var isNearEnd = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 커스텀 네비게이션 바
                CustomNavigationBar(
                    title: "FEED",
                    showBackButton: false,
                    onBackTapped: {
                        // 뒤로가기 액션 (향후 라우터 연동)
                        print("Back tapped")
                    },
                    rightButton: AnyView(
                        Button(action: {
                            isCreateFilterPresented = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    )
                )
                
                // 메인 콘텐츠
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 40) {
                            // Top Ranking 섹션
                            TopRankingSectionView(
                                selectedRankingType: Binding(
                                    get: { store.state.selectedRankingType },
                                    set: { store.send(.changeRankingType($0)) }
                                ),
                                popularityRanking: store.state.topRankingFilters[.popularity] ?? [],
                                purchaseRanking: store.state.topRankingFilters[.purchase] ?? [],
                                latestRanking: store.state.topRankingFilters[.latest] ?? [],
                                onFilterTapped: { filter in
                                    store.send(.filterTapped(filter.id))
                                }
                            )
                            .padding(.top, 20)
                            .redacted(reason: store.state.shouldShowTopRankingSkeleton ? .placeholder : [])
                            
                            // Filter Feed 섹션
                            FilterFeedSectionView(
                                filters: store.state.updatedFilters,
                                onFilterTapped: { filter in
                                    store.send(.filterTapped(filter.id))
                                },
                                onLikeTapped: { filter in
                                    store.send(.toggleLike(filter.id))
                                }
                            )
                            .redacted(reason: store.state.shouldShowFiltersSkeleton ? .placeholder : [])
                            
                            // MARK: - Improved Prefetching Logic
                            // 스크롤 끝에 가까워졌을 때만 prefetch 트리거
                            if store.state.hasMoreFilters && !store.state.isLoadingMore && !store.state.updatedFilters.isEmpty {
                                let shouldTriggerPrefetch = store.state.updatedFilters.count > 0
                                
                                if shouldTriggerPrefetch {
                                    GeometryReader { geometry in
                                        Color.clear
                                            .onAppear {
                                                // 한 번만 트리거되도록 인덱스 체크
                                                let currentCount = store.state.updatedFilters.count
                                                if currentCount > lastLoadedIndex {
                                                    print("🔄 [Prefetch] 트리거됨 - 아이템 수: \(currentCount)")
                                                    lastLoadedIndex = currentCount
                                                    
                                                    // 약간의 지연을 주어 중복 호출 방지
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        if !store.state.isLoadingMore {
                                                            store.send(.loadMoreFilters)
                                                        }
                                                    }
                                                }
                                            }
                                    }
                                    .frame(height: 1)
                                }
                            }
                            
                            // 로딩 더 보기 인디케이터
                            if store.state.isLoadingMore {
                                ProgressView()
                                    .padding()
                            }
                            
                            // 최대 재시도 도달 시 오류 메시지
                            if store.state.hasReachedMaxRetry {
                                VStack(spacing: 16) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 48))
                                        .foregroundColor(.yellow)
                                    
                                    Text("네트워크 오류")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(store.state.filtersError ?? "알 수 없는 오류가 발생했습니다.")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                    
                                    Button(action: {
                                        store.send(.refreshFilters)
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("새로고침")
                                        }
                                        .font(.body)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                    }
                                    .padding(.top, 8)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            }
                        }
                        .padding(.bottom, 100) // 탭바 영역을 위한 패딩
                        .id("top")  // LazyVStack 전체를 앵커로 사용
                    }
                    .onChange(of: scrollManager.scrollToTopTrigger) { _ in
                        // ScrollResetManager 트리거가 변경되면 맨 위로 스크롤
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                        print("📜 [FilterFeed] 탭 재선택으로 스크롤 맨 위로 이동")
                    }
                    .onChange(of: store.state.shouldRestoreScrollPosition) { shouldRestore in
                        // 상세화면에서 돌아왔을 때 스크롤 위치 복원
                        if shouldRestore {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let targetIndex = store.state.lastViewedFilterIndex
                                if targetIndex > 0 && targetIndex < store.state.updatedFilters.count {
                                    let targetId = store.state.updatedFilters[targetIndex].id
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(targetId, anchor: .center)
                                    }
                                    print("📍 [Restore] 스크롤 위치 복원: 인덱스 \(targetIndex)")
                                }
                                store.send(.resetViewState)
                            }
                        }
                    }
                }
            }
            .background(Color.black)
            .navigationBarHidden(true)
            .onAppear {
                // 탭바 표시 확인 (안전장치)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        tabBarVisibility.forceShowTabBar()
                    }
                }
                
                // 초기 로드가 필요한 경우에만 데이터 로드
                if !store.state.hasInitiallyLoadedTopRanking {
                    print("🚀 [FilterFeed] onAppear - TopRanking 초기 로드")
                    store.send(.loadTopRanking)
                }
                
                if !store.state.hasInitiallyLoadedFilters {
                    print("🚀 [FilterFeed] onAppear - Filters 초기 로드")
                    store.send(.loadFilters)
                } else {
                    print("🔄 [FilterFeed] onAppear - 이미 로드됨, API 호출 스킵")
                }
            }
            .overlay(
                // 로딩 인디케이터
                Group {
                    if store.state.isLoading && store.state.filters.isEmpty {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("필터를 불러오는 중...")
                                .foregroundColor(.white)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.7))
                    }
                }
            )
            
            // 숨겨진 NavigationLink (프로그래매틱 네비게이션용)
            NavigationLink(
                destination: FilterCreateView(),
                isActive: $isCreateFilterPresented
            ) {
                EmptyView()
            }
            .hidden()
        }
    }
} 