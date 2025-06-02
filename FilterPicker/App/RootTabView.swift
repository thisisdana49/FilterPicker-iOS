//
//  RootTabView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationView {
                        MainView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                case .feed:
                    NavigationView {
                        FeedView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                case .filter:
                    NavigationView {
                        FilterFeedView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                case .search:
                    NavigationView {
                        SearchView()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                case .profile:
                    MyPageView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            
            CustomTabBarView(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

// 임시 View 선언 (실제 구현 시 교체)
//struct MainView: View { var body: some View { Color.clear } }
struct FeedView: View { var body: some View { Color.clear } }
struct SearchView: View { var body: some View { Color.clear } }
//struct MyPageView: View { var body: some View { Color.clear } }
