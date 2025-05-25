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
            
        case .updateIntroduction(let introduction):
            state.introduction = introduction
            
        case .logout:
            // 로그아웃 처리
            break
        }
    }
} 