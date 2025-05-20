//
//  MainView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//


import SwiftUI

struct TodayFilterSectionModel {
    let imageName: String
    let title: String
    let subtitle: String
    let description: String
    let buttonTitle: String
}

private let mockTodayFilter = TodayFilterSectionModel(
    imageName: "main_sample",
    title: "새싹을 담은 필터\n청록 새록",
    subtitle: "오늘의 필터 소개",
    description: "햇살 아래 돌아나는 새싹처럼,\n맑고 투명한 빛을 담은 자연 감성 필터입니다.\n너무 과하지 않게, 부드러운 색감으로 분위기를 살려줍니다.\n새로운 시작, 순수한 감정을 담고 싶을 때 이 필터를 사용해보세요.",
    buttonTitle: "사용해보기"
)

struct MainView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                TodayFilterSectionView(model: mockTodayFilter)
                FilterCategorySectionView()
                TrendingBannerSectionView()
                TrendingFilterSectionView()
                TodayCreatorSectionView()
            }
            .padding(.vertical, 16)
        }
        .background(Color.blackTurquoise)
        .ignoresSafeArea()
    }
}

#Preview {
    MainView()
}
