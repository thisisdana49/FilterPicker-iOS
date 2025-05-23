import Foundation

struct ErrorResponse: Decodable {
    let message: String
}

enum AuthError: LocalizedError {
    case invalidRefreshToken
    case expiredRefreshToken
    case networkError
    case unknownError
    case invalidRequest
    case invalidCredentials
    case userAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .invalidRefreshToken:
            return "인증할 수 없는 리프레시 토큰입니다."
        case .expiredRefreshToken:
            return "리프레시 토큰이 만료되었습니다. 다시 로그인 해주세요."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        case .invalidRequest:
            return "필수값을 채워주세요."
        case .invalidCredentials:
            return "계정을 확인해주세요."
        case .userAlreadyExists:
            return "이미 가입된 유저입니다."
        }
    }
    
    var logMessage: String {
        switch self {
        case .invalidRefreshToken:
            return "❌ 인증할 수 없는 리프레시 토큰"
        case .expiredRefreshToken:
            return "❌ 리프레시 토큰 만료"
        case .networkError:
            return "❌ 네트워크 오류"
        case .unknownError:
            return "❌ 알 수 없는 오류"
        case .invalidRequest:
            return "❌ 필수값 누락"
        case .invalidCredentials:
            return "❌ 계정 확인 필요"
        case .userAlreadyExists:
            return "❌ 이미 가입된 유저"
        }
    }
} 