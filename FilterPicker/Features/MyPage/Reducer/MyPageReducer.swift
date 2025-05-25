import Foundation

struct MyPageReducer {
    static func reduce(state: inout MyPageState, intent: MyPageIntent) {
        switch intent {
        case .fetchProfile:
            state.isLoading = true
            state.error = nil
            
        case .saveProfile:
            state.isSaving = true
            state.error = nil
            
        case .uploadProfileImage:
            state.isUploadingImage = true
            state.uploadError = nil
            
        case .updateProfileImageURL:
            state.isUploadingImage = false
            
        case .updateName(let name):
            state.name = name
            state.isEditing = true
            
        case .updateIntroduction(let introduction):
            state.introduction = introduction
            state.isEditing = true
            
        case .startEditing:
            state.isEditing = true
            
        case .cancelEditing:
            state.isEditing = false
            state.name = ""
            state.introduction = ""
            
        case .logout:
            // 로그아웃 처리
            break
        }
    }
} 