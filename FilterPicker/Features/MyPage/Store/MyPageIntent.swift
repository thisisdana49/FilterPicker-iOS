import Foundation

enum MyPageIntent {
    case fetchProfile
    case updateName(String)
    case updateNick(String)
    case updateIntroduction(String)
    case updatePhoneNum(String)
    case uploadProfileImage(Data)
    case addHashTag(String)
    case removeHashTag(String)
    case saveProfile
    case logout
} 