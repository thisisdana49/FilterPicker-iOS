//
//  MainView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//


import SwiftUI

struct MainView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                TodayFilterSectionView()
                FilterCategorySectionView()
                TrendingFilterSectionView()
                TodayCreatorSectionView()
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    MainView()
} 
