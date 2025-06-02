//
//  CustomNavigationBar.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import SwiftUI

struct CustomNavigationBar: View {
  let title: String
  let showBackButton: Bool
  let onBackTapped: (() -> Void)?
  
  init(
    title: String,
    showBackButton: Bool = true,
    onBackTapped: (() -> Void)? = nil
  ) {
    self.title = title
    self.showBackButton = showBackButton
    self.onBackTapped = onBackTapped
  }
  
  var body: some View {
    HStack {
      if showBackButton {
        Button(action: {
          onBackTapped?()
        }) {
          Image(systemName: "chevron.left")
            .font(.title2)
//            .fontWeight(.medium)
            .foregroundColor(.white)
        }
      } else {
        Spacer()
          .frame(width: 24)
      }
      
      Spacer()
      
      Text(title)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.white)
//        .letterSpacing(2)
      
      Spacer()
      
      // 우측 여백 (대칭을 위한)
      Spacer()
        .frame(width: 24)
    }
    .padding(.horizontal, 16)
    .frame(height: 44)
    .background(Color.black)
  }
}

#Preview {
  VStack(spacing: 0) {
    CustomNavigationBar(
      title: "FEED",
      showBackButton: true,
      onBackTapped: {
        print("Back tapped")
      }
    )
    
    Spacer()
  }
  .background(Color.black)
} 
