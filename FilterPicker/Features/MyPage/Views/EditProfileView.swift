//
//  EditProfileView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/25/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var store: MyPageStore
    @State private var showingImagePicker = false
    @State private var newHashTag = ""
    
    init(store: MyPageStore) {
        _store = StateObject(wrappedValue: store)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 프로필 이미지 섹션
                    profileImageSection
                    
                    // MARK: - 프로필 정보 섹션
                    profileInfoSection
                    
                    // MARK: - 해시태그 섹션
                    hashTagsSection
                }
                .padding()
            }
            .navigationTitle("프로필 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        store.dispatch(.saveProfile)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 프로필 이미지 섹션
    private var profileImageSection: some View {
        VStack {
            if let image = store.state.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
            }
            
            Button(action: { showingImagePicker = true }) {
                Text("프로필 이미지 변경")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: Binding(
                    get: { store.state.profileImage ?? UIImage() },
                    set: { newImage in
                        if let imageData = newImage.jpegData(compressionQuality: 0.8) {
                            store.dispatch(.uploadProfileImage(imageData))
                        }
                    }
                ))
            }
        }
    }
    
    // MARK: - 프로필 정보 섹션
    private var profileInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("프로필 정보")
                .font(.system(size: 18, weight: .bold))
            
            VStack(spacing: 12) {
                profileField(title: "이름", text: Binding(
                    get: { store.state.name },
                    set: { store.dispatch(.updateName($0)) }
                ))
                
                profileField(title: "닉네임", text: Binding(
                    get: { store.state.nick },
                    set: { store.dispatch(.updateNick($0)) }
                ))
                
                profileField(title: "소개", text: Binding(
                    get: { store.state.introduction },
                    set: { store.dispatch(.updateIntroduction($0)) }
                ), isMultiline: true)
                
                profileField(title: "전화번호", text: Binding(
                    get: { store.state.phoneNum },
                    set: { store.dispatch(.updatePhoneNum($0)) }
                ))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - 해시태그 섹션
    private var hashTagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("해시태그")
                .font(.system(size: 18, weight: .bold))
            
            VStack(spacing: 12) {
                // 해시태그 입력 필드
                HStack {
                    TextField("해시태그 입력", text: $newHashTag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addHashTag) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                // 해시태그 목록
                // FlowLayout(spacing: 8) {
                //     ForEach(store.state.hashTags, id: \.self) { tag in
                //         HashTagView(tag: tag) {
                //             store.dispatch(.removeHashTag(tag))
                //         }
                //     }
                // }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - 프로필 필드 뷰
    private func profileField(title: String, text: Binding<String>, isMultiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            if isMultiline {
                TextEditor(text: text)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                TextField(title, text: text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    // MARK: - 해시태그 추가
    private func addHashTag() {
        let tag = newHashTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tag.isEmpty && !store.state.hashTags.contains(tag) {
            store.dispatch(.addHashTag(tag))
            newHashTag = ""
        }
    }
}

// MARK: - 해시태그 뷰
struct HashTagView: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.system(size: 14))
                .foregroundColor(.blue)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - FlowLayout
// struct FlowLayout: View {
    // var spacing: CGFloat = 8
    // var content: [AnyView]
    
    // init<Data: RandomAccessCollection>(
    //     spacing: CGFloat = 8,
    //     @ViewBuilder content: @escaping () -> ForEach<Data, Data.Element, AnyView>
    // ) where Data.Element: Hashable {
    //     self.spacing = spacing
    //     self.content = content().data.map { AnyView($0) }
    // }
    
    // var body: some View {
    //     GeometryReader { geometry in
    //         self.generateContent(in: geometry)
    //     }
    // }
    
    // private func generateContent(in geometry: GeometryProxy) -> some View {
    //     var width = CGFloat.zero
    //     var height = CGFloat.zero
    //     var lastHeight = CGFloat.zero
        
    //     return ZStack(alignment: .topLeading) {
    //         ForEach(Array(content.enumerated()), id: \.offset) { index, view in
    //             view
    //                 .padding(.horizontal, spacing)
    //                 .padding(.vertical, spacing)
    //                 .alignmentGuide(.leading) { dimension in
    //                     if abs(width - dimension.width) > geometry.size.width {
    //                         width = 0
    //                         height -= lastHeight
    //                         lastHeight = 0
    //                     }
    //                     let result = width
    //                     if index == content.count - 1 {
    //                         width = 0
    //                     } else {
    //                         width -= dimension.width
    //                     }
    //                     return result
    //                 }
    //                 .alignmentGuide(.top) { _ in
    //                     let result = height
    //                     if index == content.count - 1 {
    //                         height = 0
    //                     }
    //                     return result
    //                 }
    //         }
    //     }
    // }
// } 