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
                profileField(title: "소개", text: Binding(
                    get: { store.state.introduction },
                    set: { store.dispatch(.updateIntroduction($0)) }
                ), isMultiline: true)
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
} 