import SwiftUI

struct MyPageState {
    var name: String = ""
    var bio: String = ""
    var profileImage: UIImage?
    var profileImageURL: String?
    var isLoading: Bool = false
    var error: Error?
    
    // 프로필 수정 상태
    var isEditing: Bool = false
    var isSaving: Bool = false
    
    // 이미지 업로드 상태
    var isUploadingImage: Bool = false
    var uploadError: Error?
} 