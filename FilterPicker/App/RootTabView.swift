//
//  RootTabView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

// MARK: - TabBar Visibility Manager
class TabBarVisibilityManager: ObservableObject {
    @Published var isTabBarHidden: Bool = false
    
    func hideTabBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTabBarHidden = true
        }
    }
    
    func showTabBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTabBarHidden = false
        }
    }
    
    func forceShowTabBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTabBarHidden = false
        }
    }
}

// MARK: - Scroll Reset Manager
class ScrollResetManager: ObservableObject {
    @Published var scrollToTopTrigger: UUID = UUID()
    
    func resetScroll() {
        scrollToTopTrigger = UUID()
    }
}

struct RootTabView: View {
    @State private var selectedTab: TabItem = .home
    @StateObject private var tabBarVisibility = TabBarVisibilityManager()
    
    // MARK: - Lazy Loading State
    @State private var loadedTabs: Set<TabItem> = [.home] // 홈탭은 기본 로드
    
    // MARK: - Scroll Reset State
    @StateObject private var scrollManager = ScrollResetManager()
    
    private func resetScrollForTab(_ tab: TabItem) {
        // 현재 선택된 탭이 해당 탭일 때만 스크롤 리셋
        if selectedTab == tab {
            scrollManager.resetScroll()
            print("📜 [RootTab] \(tab) 탭 스크롤 리셋 트리거")
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Lazy Loading으로 탭 View 배치
            ZStack {
                // Home Tab
                if loadedTabs.contains(.home) {
                    NavigationView {
                        MainView()
                            .environmentObject(scrollManager)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .opacity(selectedTab == .home ? 1 : 0)
                    .zIndex(selectedTab == .home ? 1 : 0)
                }
                
                // Feed Tab  
                if loadedTabs.contains(.feed) {
                    NavigationView {
                        FeedView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .opacity(selectedTab == .feed ? 1 : 0)
                    .zIndex(selectedTab == .feed ? 1 : 0)
                }
                
                // Filter Tab
                if loadedTabs.contains(.filter) {
                    NavigationView {
                        FilterFeedView()
                            .environmentObject(scrollManager)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .opacity(selectedTab == .filter ? 1 : 0)
                    .zIndex(selectedTab == .filter ? 1 : 0)
                }
                
                // Search Tab
                if loadedTabs.contains(.search) {
                    NavigationView {
                        SearchView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .opacity(selectedTab == .search ? 1 : 0)
                    .zIndex(selectedTab == .search ? 1 : 0)
                }
                
                // Profile Tab
                if loadedTabs.contains(.profile) {
                    MyPageView()
                        .opacity(selectedTab == .profile ? 1 : 0)
                        .zIndex(selectedTab == .profile ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)  // 모든 View와 통일된 검정 배경
            .environmentObject(tabBarVisibility)
            .onChange(of: selectedTab) { newTab in
                // 탭 선택 시 해당 탭을 로드된 목록에 추가
                if !loadedTabs.contains(newTab) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        loadedTabs.insert(newTab)
                    }
                    print("🚀 [TabView] \(newTab) 탭 새로 로드됨")
                } else {
                    print("🔄 [TabView] \(newTab) 탭 이미 로드됨")
                }
            }
            
            // 탭바 숨김 상태에 따라 조건부 렌더링
            if !tabBarVisibility.isTabBarHidden {
                CustomTabBarView(
                    selectedTab: $selectedTab,
                    onTabReselected: { tab in
                        resetScrollForTab(tab)
                    }
                )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .animation(.easeInOut(duration: 0.3), value: tabBarVisibility.isTabBarHidden)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// 임시 View 선언 (실제 구현 시 교체)
//struct MainView: View { var body: some View { Color.clear } }
struct FeedView: View { var body: some View { Color.clear } }
struct SearchView: View { var body: some View { Color.clear } }
//struct MyPageView: View { var body: some View { Color.clear } }
