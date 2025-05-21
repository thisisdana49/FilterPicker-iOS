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
                VStack {
                    // TODO: 이미지 처리 로직 추가 필요
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("오늘의 필터 소개")
                        .fontStyle(.body3)
                        .foregroundColor(.gray60)
                        .padding(.bottom, 4)
                    Text("\(todayFilter.introduction)\n\(todayFilter.title)")
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .fontStyle(.mulgyeolTitle1)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    Text(todayFilter.description)
                        .fontStyle(.caption1)
                        .foregroundColor(.gray60)
                }
                .padding(.horizontal, 0)
                .padding(.bottom, 36)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.clear)
                
                Button(action: {}) {
                    Text("사용해보기")
                        .fontStyle(.caption1)
                        .foregroundColor(.gray60)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(16)
                }
                .padding(24)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .onAppear {
            store.dispatch(.fetchTodayFilter)
        }
    }
}

#Preview {
    TodayFilterSectionView(store: MainStore())
}

