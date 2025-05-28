//
//  RankingFilterCard.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct RankingFilterCard: View {
  let filter: Filter
  let onTapped: () -> Void
  
  private var gradientColors: [Color] {
    switch filter.ranking {
    case 1:
        return [Color.green, Color.accentColor]
    case 2:
      return [Color.purple, Color.pink]
    case 3:
      return [Color.orange, Color.yellow]
    default:
      return [Color.gray, Color.secondary]
    }
  }
  
  var body: some View {
    Button(action: onTapped) {
      VStack(spacing: 16) {
        // 프로필 이미지 영역
        ZStack {
          // 그라데이션 배경
          Circle()
            .fill(
              LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 180, height: 180)
          
          // 필터 이미지
//          URLImageView(url: filter.thumbnailURL)
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 140, height: 140)
//            .clipShape(Circle())
//            .overlay(
//              Circle()
//                .stroke(Color.white, lineWidth: 3)
//            )
        }
        
        VStack(spacing: 8) {
          // 작성자 정보
          Text(filter.creatorName)
            .font(.caption)
            .foregroundColor(.gray)
          
          // 필터 제목
          Text(filter.title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
          
          // 해시태그
          Text(filter.hashtags.joined(separator: " "))
            .font(.caption)
            .foregroundColor(.gray)
        }
        
        // 순위 표시
        if let ranking = filter.ranking {
          Text("\(ranking)")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 40, height: 40)
            .background(
              Circle()
                .fill(Color.black.opacity(0.7))
            )
        }
      }
      .frame(width: 200)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 20) {
      ForEach(MockData.topRankingFilters) { filter in
        RankingFilterCard(filter: filter) {
          print("Tapped filter: \(filter.title)")
        }
      }
    }
    .padding(.horizontal, 20)
  }
  .background(Color.black)
} 
