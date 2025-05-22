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
                .padding(0)
                
                TrendingBannerSectionView()
                TrendingFilterSectionView(store: store)
                TodayCreatorSectionView(store: store)
            }
            .padding(.vertical, 20)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}
