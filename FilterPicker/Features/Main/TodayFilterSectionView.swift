//
//  TodayFilterSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct TodayFilterSectionView: View {
    let model: TodayFilterSectionModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
//                Image(model.imageName)
//                    .resizable()
//                    .scaledToFill()
//                    .clipped()
//                    .overlay(
//                        LinearGradient(
//                            gradient: Gradient(colors: [Color.black.opacity(0.2), Color.black.opacity(0.6)]),
//                            startPoint: .top, endPoint: .bottom
//                        )
//                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 400) // TODO: 적절한 반응형 크기로 수정 필요
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(model.subtitle)
                    .fontStyle(.body3)
                    .foregroundColor(.gray60)
                    .padding(.bottom, 4)
                Text(model.title)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .fontStyle(.mulgyeolTitle1)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                Text(model.description)
                    .fontStyle(.caption1)
                    .foregroundColor(.gray60)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.clear)
            
            Button(action: {}) {
                Text(model.buttonTitle)
                    .fontStyle(.caption1)
                    .foregroundColor(.gray60)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(16)
            }
            .padding(24)
        }
        .frame(height: 400) // TODO: 적절한 반응형 크기로 수정 필요
        
    }
}

//#Preview {
//  TodayFilterSectionView(model: mockTodayFilter)
//}

