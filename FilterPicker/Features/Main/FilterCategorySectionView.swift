//
//  FilterCategorySectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct FilterCategory {
    let name: String
    let iconName: String
}

private let mockCategories: [FilterCategory] = [
    .init(name: "푸드", iconName: "IconFood"),
    .init(name: "인물", iconName: "IconPeople"),
    .init(name: "풍경", iconName: "IconLandscape"),
    .init(name: "야경", iconName: "IconNight"),
    .init(name: "별", iconName: "IconStar")
]

struct FilterCategorySectionView: View {
    let categories: [FilterCategory] = mockCategories
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(categories, id: \.name) { category in
                VStack(spacing: 4) {
                    Icon(name: category.iconName, color: .gray60)
                        .frame(width: 32, height: 32)
                    Text(category.name)
                        .fontStyle(.caption2)
                        .foregroundColor(.gray60)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    FilterCategorySectionView()
}
