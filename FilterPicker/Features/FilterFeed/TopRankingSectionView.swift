//
//  TopRankingSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct TopRankingSectionView: View {
  @Binding var selectedRankingType: FilterRankingType
  let popularityRanking: [Filter]
  let purchaseRanking: [Filter]
  let latestRanking: [Filter]
  let onFilterTapped: (Filter) -> Void
  
  private var currentFilters: [Filter] {
    switch selectedRankingType {
    case .popularity:
      return popularityRanking
    case .purchase:
      return purchaseRanking
    case .latest:
      return latestRanking
    }
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      // 섹션 제목
      Text("Top Ranking")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding(.horizontal, 20)
      
      // 랭킹 타입 탭 선택
      HStack(spacing: 12) {
        ForEach(FilterRankingType.allCases, id: \.self) { type in
          rankingTypeTab(for: type)
        }
        
        Spacer()
      }
      .padding(.horizontal, 20)
      
      // 필터 카드 리스트
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 20) {
          ForEach(currentFilters) { filter in
            RankingFilterCard(filter: filter) {
              onFilterTapped(filter)
            }
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }
  
  @ViewBuilder
  private func rankingTypeTab(for type: FilterRankingType) -> some View {
    Button(action: {
      withAnimation(.easeInOut(duration: 0.2)) {
        selectedRankingType = type
      }
    }) {
      Text(type.displayName)
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(selectedRankingType == type ? .white : .gray)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(selectedRankingType == type ? Color.white.opacity(0.2) : Color.clear)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(
              selectedRankingType == type ? Color.white.opacity(0.3) : Color.gray.opacity(0.5),
              lineWidth: 1
            )
        )
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  VStack(spacing: 0) {
    TopRankingSectionView(
      selectedRankingType: .constant(.popularity),
      popularityRanking: MockData.topRankingFilters,
      purchaseRanking: MockData.topRankingFilters,
      latestRanking: MockData.topRankingFilters,
      onFilterTapped: { filter in
        print("Tapped filter: \(filter.title)")
      }
    )
    
    Spacer()
  }
  .background(Color.black)
} 