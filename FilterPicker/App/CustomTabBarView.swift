//
//  CustomTabBarView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

struct CustomTabBarView: View {
  @Binding var selectedTab: TabItem

  var body: some View {
    ZStack {
      Color(.clear)
        .frame(width: 350, height: 68)
        .background(
          Color(red: 0.42, green: 0.42, blue: 0.43).opacity(0.5)
        )
        .cornerRadius(34)
        .blur(radius: 6)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
      // (탭 아이템은 추후 추가)
    }
    .frame(height: 68)
  }
} 
