//
//  LikeButton.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct LikeButton: View {
  let isLiked: Bool
  let onTapped: () -> Void
  
  @State private var isAnimating = false
  
  var body: some View {
    Button(action: {
      onTapped()
      withAnimation(.easeInOut(duration: 0.2)) {
        isAnimating.toggle()
      }
      
      // 애니메이션 리셋
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        isAnimating = false
      }
    }) {
      Image(systemName: isLiked ? "heart.fill" : "heart")
        .font(.title3)
        .foregroundColor(isLiked ? .red : .white)
        .scaleEffect(isAnimating ? 1.3 : 1.0)
    }
  }
}

#Preview {
  VStack(spacing: 20) {
    LikeButton(isLiked: false) {
      print("Like tapped")
    }
    
    LikeButton(isLiked: true) {
      print("Unlike tapped")
    }
  }
  .padding()
  .background(Color.black)
} 