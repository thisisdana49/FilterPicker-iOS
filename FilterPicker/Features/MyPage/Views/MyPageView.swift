//
//  MyPageView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/25/25.
//

import SwiftUI
import UIKit

struct MyPageView: View {
    @StateObject private var store = MyPageStore()
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollViewWrapper {
                VStack(spacing: 24) {
                    // MARK: - 프로필 이미지 섹션
                    profileImageSection
                    
                    // MARK: - 프로필 정보 섹션
                    profileInfoSection
                    
                    // MARK: - 설정 섹션
                    settingsSection
                }
                .padding()
            } onRefresh: {
                Task {
                    store.dispatch(.fetchProfile)
                }
            }
            .navigationTitle("마이페이지")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(store: store)
            }
            .onAppear {
                // View가 처음 나타날 때만 프로필을 가져옵니다
                if store.state.userId.isEmpty {
                    store.dispatch(.fetchProfile)
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
        }
    }
    
    // MARK: - 프로필 정보 섹션
    private var profileInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("프로필 정보")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Button(action: { showingEditProfile = true }) {
                    Text("수정")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 12) {
                profileInfoRow(title: "이름", content: store.state.nick)
                profileInfoRow(title: "소개", content: store.state.introduction)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - 설정 섹션
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("설정")
                .font(.system(size: 18, weight: .bold))
            
            Button(action: { showingLogoutAlert = true }) {
                HStack {
                    Text("로그아웃")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - 프로필 정보 행
    private func profileInfoRow(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Text(content.isEmpty ? "-" : content)
                .font(.system(size: 16))
        }
    }
}

// MARK: - ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - ScrollViewWrapper (수정된 버전)
struct ScrollViewWrapper<Content: View>: UIViewRepresentable {
    let content: Content
    let onRefresh: () -> Void
    
    init(@ViewBuilder content: () -> Content, onRefresh: @escaping () -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh(_:)),
            for: .valueChanged
        )
        
        // UIHostingController를 Coordinator에서 관리
        let hostingController = UIHostingController(rootView: content)
        context.coordinator.hostingController = hostingController
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = UIColor.clear
        
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // 상태 변경 시 UIHostingController의 rootView 업데이트
        context.coordinator.hostingController?.rootView = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: ScrollViewWrapper
        var hostingController: UIHostingController<Content>?
        
        init(_ parent: ScrollViewWrapper) {
            self.parent = parent
        }
        
        @objc func handleRefresh(_ sender: UIRefreshControl) {
            parent.onRefresh()
            sender.endRefreshing()
        }
    }
}
