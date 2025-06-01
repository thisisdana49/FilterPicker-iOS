//
//  FilterFeedCard.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct FilterFeedCard: View {
  let filter: Filter
  let onTapped: () -> Void
  let onLikeTapped: () -> Void
  
  @State private var isShowingDetail = false
  
  var body: some View {
    Button(action: {
      isShowingDetail = true
    }) {
      HStack(spacing: 16) {
        // 필터 썸네일 (필터 적용된 이미지)
        if let url = URL(string: filter.filteredImageURL) {
          URLImageView(url: url, showOverlay: false)
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        
        // 필터 정보
        VStack(alignment: .leading, spacing: 4) {
          // 제목
          Text(filter.title)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
          
          // 해시태그
          Text(filter.hashtags.joined(separator: " "))
            .font(.caption)
            .foregroundColor(.blue)
          
          // 작성자
          Text(filter.creatorName)
            .font(.subheadline)
            .foregroundColor(.gray)
          
          // 설명 텍스트 (더미)
          Text("푸르른 여름저녁 마음에 스며드는, 고요하고 깊은 감성의 정복빛 필터")
            .font(.caption)
            .foregroundColor(.gray)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
        }
        
        Spacer()
        
        // 좋아요 버튼
        VStack {
          LikeButton(
            isLiked: filter.isLiked,
            onTapped: onLikeTapped
          )
          
          Spacer()
        }
      }
      .padding(.vertical, 8)
      .contentShape(Rectangle())
    }
    .buttonStyle(PlainButtonStyle())
    .sheet(isPresented: $isShowingDetail) {
      FilterDetailView(filterId: filter.id)
    }
  }
}

#Preview {
  VStack(spacing: 0) {
    ForEach(MockData.filterFeedItems) { filter in
      FilterFeedCard(
        filter: filter,
        onTapped: {
          print("Tapped filter: \(filter.title)")
        },
        onLikeTapped: {
          print("Like tapped for: \(filter.title)")
        }
      )
      .padding(.horizontal, 20)
      
      Divider()
        .background(Color.gray.opacity(0.3))
    }
  }
  .background(Color.black)
} 
