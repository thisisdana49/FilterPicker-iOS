import Foundation
import SwiftUI

@MainActor
final class MyPageStore: ObservableObject {
    @Published private(set) var state: MyPageState
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository = UserRepository()) {
        self.state = MyPageState()
        self.userRepository = userRepository
        
        Task {
            await fetchProfile()
        }
    }
    
    func dispatch(_ intent: MyPageIntent) {
        MyPageReducer.reduce(state: &state, intent: intent)
        
        switch intent {
        case .fetchProfile:
            Task {
                await fetchProfile()
            }
            
        case .saveProfile:
            Task {
                await saveProfile()
            }
            
        case .uploadProfileImage(let data):
            Task {
                await uploadProfileImage(data)
            }
            
        case .updateProfileImageURL(let url):
            state.profileImageURL = url
            if let url = URL(string: url),
               let data = try? Data(contentsOf: url) {
                state.profileImage = UIImage(data: data)
            }
            
        case .updateName, .updateBio, .logout:
            break
        }
    }
    
    private func fetchProfile() async {
        do {
            let profile = try await userRepository.fetchMyProfile()
            state.name = profile.name
            state.bio = profile.bio
            state.profileImageURL = profile.profileImageURL
            
            if let url = profile.profileImageURL,
               let imageUrl = URL(string: url),
               let data = try? Data(contentsOf: imageUrl) {
                state.profileImage = UIImage(data: data)
            }
            
            state.isLoading = false
        } catch {
            state.error = error
            state.isLoading = false
        }
    }
    
    private func saveProfile() async {
        do {
            let request = EditProfileRequest(
                name: state.name,
                bio: state.bio,
                profileImageURL: state.profileImageURL
            )
            
            try await userRepository.updateMyProfile(request)
            state.isSaving = false
            state.isEditing = false
        } catch {
            state.error = error
            state.isSaving = false
        }
    }
    
    private func uploadProfileImage(_ data: Data) async {
        do {
            let imageURL = try await userRepository.uploadProfileImage(data)
            await dispatch(.updateProfileImageURL(imageURL))
        } catch {
            state.uploadError = error
            state.isUploadingImage = false
        }
    }
} 