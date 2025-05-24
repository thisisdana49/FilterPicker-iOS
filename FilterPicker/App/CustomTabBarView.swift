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
            // 블러 효과가 적용된 배경
            RoundedRectangle(cornerRadius: 34)
                .fill(.ultraThinMaterial)
                .frame(width: 350, height: 68)
                .background(
                    Color(red: 0.42, green: 0.42, blue: 0.43).opacity(0.5)
                )
                .cornerRadius(34)
                .overlay(
                    RoundedRectangle(cornerRadius: 34)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.42, green: 0.42, blue: 0.43).opacity(0.5), lineWidth: 1)
                )
            
            // 탭 아이템
            HStack(spacing: 0) {
                ForEach(TabItem.allCases) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack(spacing: 0) {
                            // 인디케이터 (상단에 딱 붙게)
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white)
                                    .frame(width: 24, height: 4)
                                    .shadow(color: .white.opacity(0.6), radius: 4)
                            } else {
                                Spacer().frame(height: 4)
                            }
                            Spacer().frame(height: 8) // 인디케이터와 아이콘 사이 여백
                            Image(tab.iconAssetName(isSelected: selectedTab == tab))
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 28, height: 28)
                                .foregroundColor(selectedTab == tab ? .gray15 : .gray45)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(width: 320, height: 56)
        }
        .frame(height: 68)
    }
}
