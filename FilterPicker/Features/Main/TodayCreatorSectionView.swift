//
//  TodayCreatorSectionView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/20/25.
//

import SwiftUI

struct CreatorMock {
    let profileImage: String
    let name: String
    let engName: String
    let works: [String]
    let tags: [String]
    let quote: String
    let description: String
}

private let mockCreator = CreatorMock(
    profileImage: "creator_profile",
    name: "윤새싹",
    engName: "SESAC YOON",
    works: ["work1", "work2", "work3"],
    tags: ["#섬세함", "#자연", "#미니멀"],
    quote: "\"자연의 섬세함을 담아내는 감성 사진작가\"",
    description: "윤새싹은 자연의 섬세한 아름다움을 포착하는 데 탁월한 감각을 지닌 사진작가입니다. 그녀의 작품은 일상 속에서 쉽게 지나칠 수 있는 순간들을 특별하게 담아내며, 관람객들에게 새로운 시각을 선사합니다."
)

struct TodayCreatorSectionView: View {
    let creator: CreatorMock = mockCreator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("오늘의 작가 소개")
                .fontStyle(.body1)
                .foregroundColor(.gray60)
            
            HStack(alignment: .center, spacing: 16) {
                Image(creator.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(creator.name)
                        .fontStyle(.mulgyeolBody1)
                        .foregroundColor(.white)
                    Text(creator.engName)
                        .fontStyle(.body3)
                        .foregroundColor(.gray75)
                }
            }
            
            HStack(spacing: 12) {
                ForEach(creator.works, id: \.self) { img in
                    Image(img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 80)
                        .cornerRadius(12)
                        .clipped()
                }
            }
            
            HStack(spacing: 8) {
                ForEach(creator.tags, id: \.self) { tag in
                    Text(tag)
                        .fontStyle(.caption1)
                        .foregroundColor(.gray60)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.gray90)
                        .cornerRadius(8)
                }
            }
            
            Text(creator.quote)
                .fontStyle(.mulgyeolCaption1)
                .foregroundColor(.gray30)
                .padding(.top, 8)
            
            Text(creator.description)
                .fontStyle(.body3)
                .foregroundColor(.gray60)
                .padding(.top, 4)
        }
        .padding(.horizontal, 16)
    }
}
