import Foundation
import UIKit

struct MyPageState {
    // 필수 필드
    var userId: String = ""
    var email: String = ""
    var nick: String = ""
    var hashTags: [String] = []
    
    // 선택 필드
    var name: String = ""
    var introduction: String = ""
    var profileImage: UIImage?
    var profileImageURL: String?
    var phoneNum: String = ""
    
    // 상태 관리
    var isLoading: Bool = true
    var isSaving: Bool = false
    var isUploadingImage: Bool = false
    var isEditing: Bool = false
    var error: Error?
    var uploadError: Error?
} 