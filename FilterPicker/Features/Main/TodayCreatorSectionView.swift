//
//  TodayCreatorSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct TodayCreatorSectionView: View {
    @ObservedObject var store: MainStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 작가")
                .fontStyle(.body1)
                .foregroundColor(.gray60)
                .padding(.leading, 16)

            if let author = store.state.todayAuthor {
                HStack(alignment: .top, spacing: 16) {
                    if let profile = author.profileImage,
                       let url = URL(string: AppConfig.baseURL + "/v1/" + profile) {
                        URLImageView(url: url, showOverlay: false)
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray30)
                            .frame(width: 64, height: 64)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(author.name)
                            .fontStyle(.body2)
                            .foregroundColor(.white)
                        Text(author.introduction)
                            .fontStyle(.caption1)
                            .foregroundColor(.gray60)
                        HStack(spacing: 4) {
                            ForEach(author.hashTags, id: \.self) { tag in
                                Text(tag)
                                    .fontStyle(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                // 캐러셀: 상위 5개 필터 이미지
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.state.hotTrendFilters.prefix(5), id: \.filterId) { filter in
                            if let firstFile = filter.files.first,
                               let url = URL(string: AppConfig.baseURL + "/v1/" + firstFile) {
                                URLImageView(url: url, showOverlay: false)
                                    .frame(width: 110, height: 80)
                                    .cornerRadius(12)
                                    .clipped()
                            } else {
                                Rectangle()
                                    .fill(Color.gray30)
                                    .frame(width: 110, height: 80)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Text(author.description)
                    .fontStyle(.caption1)
                    .lineSpacing(8)
                    .foregroundColor(.gray60)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            } else if store.state.isLoading {
                ProgressView()
                    .padding()
            } else if let error = store.state.error {
                Text("오류: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear {
            store.dispatch(.fetchTodayAuthor)
        }
    }
}
