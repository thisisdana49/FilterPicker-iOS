//
//  FilterCategorySectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct FilterCategoryMock {
    let name: String
    let iconName: String
}

private let mockCategories: [FilterCategoryMock] = [
    .init(name: "푸드", iconName: "IconFood"),
    .init(name: "인물", iconName: "IconPeople"),
    .init(name: "풍경", iconName: "IconLandscape"),
    .init(name: "야경", iconName: "IconNight"),
    .init(name: "별", iconName: "IconStar")
]

struct FilterCategorySectionView: View {
    let categories: [FilterCategoryMock] = mockCategories
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(categories, id: \.name) { category in
                VStack(spacing: 4) {
                    Icon(name: category.iconName, color: .gray60)
//                        .frame(width: 32, height: 32)
                    Text(category.name)
                        .fontStyle(.caption2)
                        .foregroundColor(.gray60)
                }
                .foregroundColor(.clear)
                .frame(width: 56, height: 56)
                .background(Color(red: 0.42, green: 0.42, blue: 0.43).opacity(0.5))

                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.42, green: 0.42, blue: 0.43).opacity(0.5), lineWidth: 1)
                    
                )
            }
        }
        .padding(0)
    }
}
