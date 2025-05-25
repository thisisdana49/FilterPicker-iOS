import Foundation

struct MyPageReducer {
    static func reduce(state: inout MyPageState, intent: MyPageIntent) {
        switch intent {
        case .fetchProfile:
            state.isLoading = true
            state.error = nil
            
        case .updateName(let name):
            state.name = name
            state.isEditing = true
            
        case .updateBio(let bio):
            state.bio = bio
            state.isEditing = true
            
        case .saveProfile:
            state.isSaving = true
            state.error = nil
            
        case .uploadProfileImage:
            state.isUploadingImage = true
            state.uploadError = nil
            
        case .updateProfileImageURL(let url):
            state.profileImageURL = url
            state.isUploadingImage = false
            
        case .logout:
            // 로그아웃 처리
            break
        }
    }
} 