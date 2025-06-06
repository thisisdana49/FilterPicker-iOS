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
        isTabBarHidden = true
    }
    
    func showTabBar() {
        isTabBarHidden = false
    }
    
    func forceShowTabBar() {
        isTabBarHidden = false
    }
}

struct RootTabView: View {
    @State private var selectedTab: TabItem = .home
    @StateObject private var tabBarVisibility = TabBarVisibilityManager()
    
    // MARK: - Lazy Loading State
    @State private var loadedTabs: Set<TabItem> = [.home] // 홈탭은 기본 로드
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Lazy Loading으로 탭 View 배치
            ZStack {
                // Home Tab
                if loadedTabs.contains(.home) {
                    NavigationView {
                        MainView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .opacity(selectedTab == .home ? 1 : 0)
                    .zIndex(selectedTab == .home ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
                
                // Feed Tab  
                if loadedTabs.contains(.feed) {
                    NavigationView {
                        FeedView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .opacity(selectedTab == .feed ? 1 : 0)
                    .zIndex(selectedTab == .feed ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
                
                // Filter Tab
                if loadedTabs.contains(.filter) {
                    NavigationView {
                        FilterFeedView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .opacity(selectedTab == .filter ? 1 : 0)
                    .zIndex(selectedTab == .filter ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
                
                // Search Tab
                if loadedTabs.contains(.search) {
                    NavigationView {
                        SearchView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .opacity(selectedTab == .search ? 1 : 0)
                    .zIndex(selectedTab == .search ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
                
                // Profile Tab
                if loadedTabs.contains(.profile) {
                    MyPageView()
                        .opacity(selectedTab == .profile ? 1 : 0)
                        .zIndex(selectedTab == .profile ? 1 : 0)
                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
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
                CustomTabBarView(selectedTab: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
