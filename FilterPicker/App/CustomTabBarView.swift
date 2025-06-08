//
//  CustomTabBarView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

struct CustomTabBarView: View {
    @Binding var selectedTab: TabItem
    var onTabReselected: ((TabItem) -> Void)?
    
    var body: some View {
        ZStack {
            // 블러 효과가 적용된 배경 (iOS 14 호환)
            RoundedRectangle(cornerRadius: 34)
                .fill(Color.clear)
                .frame(width: 350, height: 68)
                .background(
                    CustomBlurView(style: .systemUltraThinMaterialDark)
                        .clipShape(RoundedRectangle(cornerRadius: 34))
                )
                .cornerRadius(34)
                .overlay(
                    RoundedRectangle(cornerRadius: 34)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.42, green: 0.42, blue: 0.43).opacity(0.5), lineWidth: 1)
                )
            
            // 탭 아이템 (HStack)
            HStack(spacing: 0) {
                ForEach(TabItem.allCases) { tab in
                    Button(action: {
                        if selectedTab == tab {
                            // 현재 선택된 탭을 다시 선택한 경우
                            onTabReselected?(tab)
                            print("🔄 [TabBar] \(tab) 탭 재선택 - 스크롤 맨 위로")
                        } else {
                            // 다른 탭 선택
                            selectedTab = tab
                            print("🎯 [TabBar] \(tab) 탭 선택")
                        }
                    }) {
                        Image(tab.iconAssetName(isSelected: selectedTab == tab))
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundColor(selectedTab == tab ? .gray15 : .gray45)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(width: 320, height: 56)

            // 인디케이터 (ZStack의 최상단에, 선택된 탭의 위치에 맞춰서)
            GeometryReader { geo in
                let tabCount = TabItem.allCases.count
                let tabWidth = geo.size.width / CGFloat(tabCount)
                let indicatorX = tabWidth * CGFloat(selectedTab.rawValue) + (tabWidth - 32) / 2

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.98, green: 0.98, blue: 0.98))
                    .frame(width: 32, height: 3.7)
                    .shadow(color: .white.opacity(0.15), radius: 2, x: 0, y: 4)
                    .position(x: indicatorX + 12, y: 1)
                    .animation(.easeInOut(duration: 0.25), value: selectedTab)
            }
            .frame(width: 320, height: 8)
            .offset(y: -28) // 탭바 상단에 맞게 조정
        }
        .frame(height: 68)
    }
}
