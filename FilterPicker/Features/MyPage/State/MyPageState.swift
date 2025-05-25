import Foundation
import SwiftUI

struct MyPageState {
    var name: String = ""
    var introduction: String = ""
    var profileImage: UIImage?
    var profileImageURL: String?
    var isLoading: Bool = true
    var isSaving: Bool = false
    var isUploadingImage: Bool = false
    var isEditing: Bool = false
    var error: Error?
    var uploadError: Error?
} 