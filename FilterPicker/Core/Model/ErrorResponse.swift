import Foundation

struct ErrorResponse: Decodable {
    let message: String
}

// MARK: - Empty Response for API calls that return no data
struct EmptyResponse: Codable {}

enum NetworkError: LocalizedError {
    case invalidRequest
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)
    case tokenExpired
    case refreshTokenFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .invalidResponse:
            return "서버로부터 잘못된 응답을 받았습니다."
        case .statusCode(let code):
            return "서버 오류가 발생했습니다. (코드: \(code))"
        case .decoding(let error):
            return "응답 데이터 처리 중 오류가 발생했습니다: \(error.localizedDescription)"
        case .tokenExpired:
            return "인증이 만료되었습니다. 다시 로그인해주세요."
        case .refreshTokenFailed:
            return "토큰 갱신에 실패했습니다. 다시 로그인해주세요."
        }
    }
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
            return "❌ 인증할 수 없는 리프레시 토큰\n🔒 TokenStorage: 모든 토큰이 삭제되었습니다."
        case .expiredRefreshToken:
            return "❌ 리프레시 토큰 만료\n🔒 TokenStorage: 모든 토큰이 삭제되었습니다."
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
    
    // NetworkError를 AuthError로 변환하는 메서드
    static func from(_ networkError: NetworkError) -> AuthError {
        switch networkError {
        case .tokenExpired, .refreshTokenFailed:
            return .expiredRefreshToken
        case .invalidRequest:
            return .invalidRequest
        case .invalidResponse, .statusCode, .decoding:
            return .networkError
        }
    }
} 