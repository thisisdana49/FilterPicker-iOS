//
//  MainView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//


import SwiftUI

struct MainView: View {
    @StateObject private var store = MainStore()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                ZStack {
                    TodayFilterSectionView(store: store)
                    
                    FilterCategorySectionView()
                        .padding(.top, 463)
                }
                TrendingBannerSectionView()
                TrendingFilterSectionView(store: store)
                TodayCreatorSectionView()
            }
            .padding(.vertical, 16)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}
