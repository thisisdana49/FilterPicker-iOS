//
//  FilterDetailView.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import SwiftUI

struct FilterDetailView: View {
    let filterId: String
    @StateObject private var store = FilterDetailStore()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if store.state.isLoading {
                    ProgressView("로딩 중...")
                        .foregroundColor(.white)
                } else if let error = store.state.error {
                    VStack {
                        Text("오류가 발생했습니다")
                            .foregroundColor(.white)
                        Text(error.localizedDescription)
                            .foregroundColor(.gray)
                            .font(.caption)
                        Button("다시 시도") {
                            store.dispatch(.loadFilterDetail(filterId: filterId))
                        }
                        .foregroundColor(.blue)
                    }
                } else if let filterDetail = store.state.filterDetail {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // 새로고침 버튼
                            HStack {
                                Spacer()
                                Button(action: {
                                    store.dispatch(.refresh(filterId: filterId))
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                }
                                .padding(.trailing, 20)
                            }
                            
                            // 필터 이미지
                            if let url = URL(string: filterDetail.filteredImageURL) {
                                URLImageView(url: url, showOverlay: false)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 400)
                                    .clipped()
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                // 제목과 작성자
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(filterDetail.title)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("by \(filterDetail.creator.nick)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                // 설명
                                Text(filterDetail.description)
                                    .font(.body)
                                    .foregroundColor(.white)
                                
                                // 통계 정보
                                HStack {
                                    Button(action: {
                                        store.dispatch(.toggleLike(filterId: filterId))
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: filterDetail.isLiked ? "heart.fill" : "heart")
                                                .foregroundColor(filterDetail.isLiked ? .red : .white)
                                            Text("\(filterDetail.likeCount)")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .disabled(store.state.isLikeLoading)
                                    
                                    Spacer()
                                    
                                    Text("구매: \(filterDetail.buyerCount)")
                                        .foregroundColor(.gray)
                                    
                                    Text("₩\(filterDetail.price)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                // 카테고리
                                Text("카테고리: \(filterDetail.category)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                // 댓글 섹션
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("댓글 (\(filterDetail.comments.count))")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ForEach(filterDetail.comments) { comment in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(comment.creator.nick)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text(comment.content)
                                                .font(.body)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("닫기") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .onAppear {
            store.dispatch(.loadFilterDetail(filterId: filterId))
        }
    }
} 