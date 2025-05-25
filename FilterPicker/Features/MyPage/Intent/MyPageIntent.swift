import Foundation

enum MyPageIntent {
    // 프로필 조회
    case fetchProfile
    
    // 프로필 수정
    case updateName(String)
    case updateIntroduction(String)
    case saveProfile
    
    // 프로필 이미지
    case uploadProfileImage(Data)
    case updateProfileImageURL(String)
    
    // 로그아웃
    case logout
} 