//
//  FilterFeedView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct FilterFeedView: View {
    @StateObject private var store = FilterFeedStore()
    @State private var isCreateFilterPresented = false
    @EnvironmentObject var tabBarVisibility: TabBarVisibilityManager
    
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
                        .redacted(reason: store.state.isLoadingTopRanking ? .placeholder : [])
                        
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
                        .redacted(reason: store.state.isLoadingFilters ? .placeholder : [])
                        
                        // 로딩 더 보기 인디케이터
                        if store.state.isLoadingMore {
                            ProgressView()
                                .padding()
                        }
                        
                        // 무한 스크롤을 위한 트리거
                        if store.state.hasMoreFilters && !store.state.isLoadingMore {
                            Color.clear
                                .frame(height: 1)
                                .onAppear {
                                    store.send(.loadMoreFilters)
                                }
                        }
                    }
                    .padding(.bottom, 100) // 탭바 영역을 위한 패딩
                }
                //      .refreshable {
                //        store.send(.refreshFilters)
                //      }
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
                
                // 화면이 나타날 때 데이터 로드
                store.send(.loadTopRanking)
                store.send(.loadFilters)
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
        //    .alert("오류", isPresented: .constant(store.state.hasError)) {
        //      Button("확인") {
        //        store.send(.clearError)
        //      }
        //    } message: {
        //      Text(store.state.topRankingError ?? store.state.filtersError ?? "")
        //    }
    }
}
