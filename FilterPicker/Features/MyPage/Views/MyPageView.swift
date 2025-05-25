import SwiftUI
import UIKit

struct MyPageView: View {
    @StateObject private var store: MyPageStore
    @State private var showImagePicker = false
    
    init() {
        _store = StateObject(wrappedValue: MyPageStore())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 이미지 섹션
                    profileImageSection
                    
                    // 프로필 정보 섹션
                    profileInfoSection
                    
                    // 설정 메뉴 섹션
                    settingsSection
                }
                .padding()
            }
            .navigationTitle("마이페이지")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showImagePicker) {
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
    
    private var profileImageSection: some View {
        VStack {
            Button(action: { showImagePicker = true }) {
                if let profileImage = store.state.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
            }
            
            Text("프로필 이미지 변경")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
    
    private var profileInfoSection: some View {
        VStack(spacing: 16) {
            TextField("이름", text: Binding(
                get: { store.state.name },
                set: { store.dispatch(.updateName($0)) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("소개", text: Binding(
                get: { store.state.bio },
                set: { store.dispatch(.updateBio($0)) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("프로필 저장") {
                store.dispatch(.saveProfile)
            }
            .buttonStyle(.borderless)
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 16) {
            NavigationLink("알림 설정") {
                Text("알림 설정 화면")
            }
            
            NavigationLink("개인정보 처리방침") {
                Text("개인정보 처리방침 화면")
            }
            
            NavigationLink("이용약관") {
                Text("이용약관 화면")
            }
            
            Button("로그아웃") {
                store.dispatch(.logout)
            }
            .foregroundColor(.red)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage
    @Environment(\.presentationMode) private var presentationMode
    
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
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
