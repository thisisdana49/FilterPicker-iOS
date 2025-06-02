//
//  FilterCreateView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

struct FilterCreateView: View {
    @StateObject private var store = FilterCreateStore()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바
            CustomNavigationBar(
                title: "MAKE",
                showBackButton: true,
                onBackTapped: {
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
        .sheet(isPresented: $store.state.isImagePickerPresented) {
            FilterImagePicker { image in
                store.send(.selectImage(image))
            }
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
                
                if store.state.selectedImage != nil {
                    Button("수정하기") {
                        store.send(.presentImagePicker)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
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
                        
                        if let metadata = store.state.imageMetadata {
                            ImageMetadataView(metadata: metadata)
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

struct ImageMetadataView: View {
    let metadata: ImageMetadata
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(metadata.deviceModel)
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text("\(metadata.lensInfo) • \(metadata.resolution) • \(metadata.fileSize)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if let location = metadata.location {
                        Text(location)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
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
    let onImageSelected: (UIImage) -> Void
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
                parent.onImageSelected(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
} 
