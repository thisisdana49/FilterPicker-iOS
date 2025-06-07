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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("오늘의 작가")
                    .multilineTextAlignment(.leading)
                    .fontStyle(.body1)
                    .foregroundColor(.gray60)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            if let author = store.state.todayAuthor {
                HStack(alignment: .top, spacing: 16) {
                    if let url = URL(string: author.profileImageURL) {
                        URLImageView(url: url, showOverlay: false)
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray30)
                            .frame(width: 64, height: 64)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(author.name)
                            .fontStyle(.body2)
                            .foregroundColor(.white)
                        Text(author.nick)
                            .fontStyle(.caption1)
                            .foregroundColor(.gray60)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // 캐러셀: 상위 5개 필터 이미지
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.state.updatedHotTrendFilters.prefix(5), id: \.filterId) { filter in
                            if let url = URL(string: filter.filteredImageURL) {
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
                    .padding(.horizontal, 20)
                }
                
                HStack(spacing: 4) {
                    ForEach(author.hashTags, id: \.self) { tag in
                        Text(tag)
                            .fontStyle(.caption2)
                            .foregroundColor(.green)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .top], 20)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(author.introduction)
                        .fontStyle(.mulgyeolCaption1)
                        .foregroundColor(.gray60)
                    
                    Text(author.description)
                        .fontStyle(.caption1)
                        .lineSpacing(8)
                        .foregroundColor(.gray60)
                }
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .top], 20)
                .padding(.bottom, 41)
                
            } else if store.state.isLoading {
                ProgressView()
                    .padding()
            } else if let error = store.state.error {
                Text("오류: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 68)
        .onAppear {
            store.dispatch(.fetchTodayAuthor)
        }
    }
}
