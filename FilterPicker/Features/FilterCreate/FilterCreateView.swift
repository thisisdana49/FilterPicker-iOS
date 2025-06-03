//
//  FilterCreateView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI
import Photos

struct FilterCreateView: View {
    @StateObject private var store = FilterCreateStore()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var tabBarVisibility: TabBarVisibilityManager
    
    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바
            CustomNavigationBar(
                title: "MAKE",
                showBackButton: true,
                onBackTapped: {
                    // 탭바 다시 표시 (강제)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        tabBarVisibility.forceShowTabBar()
                    }
                    // 화면 닫기
                    presentationMode.wrappedValue.dismiss()
                },
                rightButton: AnyView(
                    Button(action: {
                        store.send(.saveFilter)
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .disabled(!store.state.isValid)
                    .opacity(store.state.isValid ? 1.0 : 0.5)
                )
            )
            
            // 메인 콘텐츠
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // 필터명 섹션
                    filterNameSection
                    
                    // 카테고리 섹션
                    categorySection
                    
                    // 대표 사진 등록 섹션
                    imageSection
                    
                    // 필터 소개 섹션
                    descriptionSection
                    
                    // 판매 가격 섹션
                    priceSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
        }
        .background(Color.black)
        .navigationBarHidden(true)
        .onAppear {
            // 탭바 숨김
            withAnimation(.easeInOut(duration: 0.3)) {
                tabBarVisibility.hideTabBar()
            }
            requestPhotoLibraryPermission()
        }
        .sheet(isPresented: $store.state.isImagePickerPresented) {
            FilterImagePicker { image, phAsset in
                store.send(.selectImage(image, phAsset))
            }
        }
//        .alert("오류", isPresented: Binding<Bool>(
//            get: { store.state.errorMessage != nil },
//            set: { _ in store.send(.clearError) }
//        )) {
//            Button("확인") {
//                store.send(.clearError)
//            }
//        } message: {
//            Text(store.state.errorMessage ?? "")
//        }
    }
    
    // MARK: - Helper Methods
    private func hideTabBar() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.tabBar.isHidden = true
            }
        }
    }
    
    private func showTabBar() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.tabBar.isHidden = false
            }
        }
    }
    
    // MARK: - 권한 요청
    private func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        print("✅ 사진 라이브러리 접근 권한 승인됨")
                    } else {
                        print("❌ 사진 라이브러리 접근 권한 거부됨")
                    }
                }
            }
        case .denied, .restricted:
            print("❌ 사진 라이브러리 접근 권한이 거부되어 있습니다.")
        case .authorized, .limited:
            print("✅ 사진 라이브러리 접근 권한이 이미 승인되어 있습니다.")
        @unknown default:
            break
        }
    }
}

// MARK: - View Components
extension FilterCreateView {
    
    private var filterNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("필터명")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            TextField("필터 이름을 입력해주세요.", text: Binding(
                get: { store.state.filterName },
                set: { store.send(.updateFilterName($0)) }
            ))
            .textFieldStyle(CustomTextFieldStyle())
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("카테고리")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    let displayCategories: [FilterCategory] = [.food, .portrait, .landscape, .night, .star]
                    ForEach(displayCategories, id: \.self) { category in
                        CategoryButton(
                            title: category.rawValue,
                            isSelected: store.state.selectedCategory == category
                        ) {
                            store.send(.selectCategory(category))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
        }
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("대표 사진 등록")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if let image = store.state.selectedImage {
                    NavigationLink(destination: 
                        FilterEditView(
                            image: image,
                            onFilterApplied: { filteredImage, filterState in
                                store.send(.setFilteredImage(filteredImage))
                                store.send(.setFilterParameters(FilterParameters(from: filterState)))
                            }
                        )
                        .environmentObject(tabBarVisibility)
                    ) {
                        Text("수정하기")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Button(action: {
                store.send(.presentImagePicker)
            }) {
                if let image = store.state.selectedImage {
                    VStack(spacing: 0) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                        
                        if let metadata = store.state.photoMetadata {
                            PhotoMetadataView(metadata: metadata)
                        } else if store.state.isExtractingMetadata {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("이미지 정보 추출 중...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 8)
                        }
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("필터 소개")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ZStack(alignment: .topLeading) {
                // 플레이스홀더 텍스트
                if store.state.filterDescription.isEmpty {
                    Text("이 필터에 대해 간단하게 소개해주세요.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: Binding(
                    get: { store.state.filterDescription },
                    set: { store.send(.updateFilterDescription($0)) }
                ))
                .font(.body)
                .foregroundColor(.white)
                .background(Color.clear)
                .frame(minHeight: 80, maxHeight: 120)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("판매 가격")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            HStack {
                TextField("1,000", text: Binding(
                    get: { store.state.price },
                    set: { store.send(.updatePrice($0)) }
                ))
                .textFieldStyle(CustomTextFieldStyle())
                .keyboardType(.numberPad)
                
                Text("원")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.leading, 8)
            }
        }
    }
}

// MARK: - Supporting Views
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                )
        }
    }
}

struct PhotoMetadataView: View {
    let metadata: PhotoMetadata
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // 카메라 정보
                    Text(metadata.camera ?? "Unknown Camera")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    // 촬영 설정 정보
                    let lensInfo = metadata.lensInfo ?? "Unknown"
                    let focalLength = metadata.focalLength ?? 0
                    let aperture = metadata.aperture ?? 0
                    let iso = metadata.iso ?? 0
                    
                    Text("\(lensInfo) • \(String(format: "%.0f", focalLength))mm f/\(String(format: "%.1f", aperture)) ISO\(iso)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    // 해상도 및 파일 정보
                    let dimensions = "\(metadata.pixelWidth) x \(metadata.pixelHeight)"
                    let fileSize = formatFileSize(metadata.fileSize)
                    
                    Text("\(dimensions) • \(fileSize) • \(metadata.format)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("EXIF")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
        }
        .padding(.top, 8)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let mb = Double(bytes) / 1024.0 / 1024.0
        return String(format: "%.1fMB", mb)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.body)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
    }
}

// MARK: - ImagePicker
struct FilterImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage, PHAsset?) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: FilterImagePicker
        
        init(_ parent: FilterImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                // PHAsset 정보도 함께 가져오기 (iOS 11+)
                let phAsset = info[.phAsset] as? PHAsset
                parent.onImageSelected(image, phAsset)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 
