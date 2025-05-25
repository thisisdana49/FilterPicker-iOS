import Foundation

enum MyPageIntent {
    // 프로필 조회
    case fetchProfile
    
    // 프로필 수정
    case updateName(String)
    case updateNick(String)
    case updateIntroduction(String)
    case updatePhoneNum(String)
    case saveProfile
    case startEditing
    case cancelEditing
    
    // 프로필 이미지
    case uploadProfileImage(Data)
    case updateProfileImageURL(String)
    
    // 해시태그
    case addHashTag(String)
    case removeHashTag(String)
    
    // 로그아웃
    case logout
} 