//
//  TodayFilterSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct TodayFilterSectionView: View {
    @ObservedObject var store: MainStore
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if store.state.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = store.state.error {
                VStack {
                    Text("오류가 발생했습니다")
                        .fontStyle(.body1)
                        .foregroundColor(.gray60)
                    Button("다시 시도") {
                        store.dispatch(.fetchTodayFilter)
                    }
                    .fontStyle(.caption1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let todayFilter = store.state.todayFilter {
                if let firstFile = todayFilter.files.first,
                   let url = URL(string: AppConfig.baseURL + "/v1/" + firstFile) {
                    URLImageView(url: url, showOverlay: true)
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 555)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("오늘의 필터 소개")
                        .fontStyle(.body3)
                        .foregroundColor(.gray60)
                        .padding(.bottom, 4)
                    Text("\(todayFilter.introduction)\n\(todayFilter.title)")
                        .fontStyle(.mulgyeolTitle1)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    Text(todayFilter.description)
                        .fontStyle(.caption1)
                        .foregroundColor(.gray60)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(8)
                        .padding(.trailing, 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 128)
                .background(Color.clear)
    
                Button(action: {}) {
                    Text("사용해보기")
                        .fontStyle(.caption1)
                        .foregroundColor(.gray60)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(16)
                }
                .padding(24)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 555)
        .padding(.horizontal, 20)
        .onAppear {
            store.dispatch(.fetchTodayFilter)
        }
    }
}
