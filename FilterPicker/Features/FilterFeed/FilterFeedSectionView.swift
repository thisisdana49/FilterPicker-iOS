//
//  FilterFeedSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct FilterFeedSectionView: View {
  let filters: [Filter]
  let onFilterTapped: (Filter) -> Void
  let onLikeTapped: (Filter) -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 섹션 헤더
      HStack {
        Text("Filter Feed")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(.white)
        
        Spacer()
        
        Button(action: {
          // List Mode 토글 액션 (향후 구현)
          print("List Mode tapped")
        }) {
          Text("List Mode")
            .font(.caption)
            .foregroundColor(.gray)
        }
        .buttonStyle(PlainButtonStyle())
      }
      .padding(.horizontal, 20)
      
      // 필터 리스트
      LazyVStack(spacing: 0) {
        ForEach(filters) { filter in
          VStack(spacing: 0) {
            FilterFeedCard(
              filter: filter,
              onTapped: {
                onFilterTapped(filter)
              },
              onLikeTapped: {
                onLikeTapped(filter)
              }
            )
            .padding(.horizontal, 20)
            
            // 구분선 (마지막 아이템 제외)
            if filter.id != filters.last?.id {
              Divider()
                .background(Color.gray.opacity(0.2))
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
          }
        }
      }
    }
  }
}

#Preview {
  ScrollView {
    FilterFeedSectionView(
      filters: MockData.filterFeedItems,
      onFilterTapped: { filter in
        print("Tapped filter: \(filter.title)")
      },
      onLikeTapped: { filter in
        print("Like tapped for: \(filter.title)")
      }
    )
  }
  .background(Color.black)
} 