import Foundation

struct JWTDecoder {
    struct JWTPayload: Decodable {
        let id: String
        let iat: Int  // 발급 시간
        let exp: Int  // 만료 시간
        let iss: String
    }
    
    static func decode(_ token: String) -> JWTPayload? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3,
              let payloadData = base64UrlDecode(parts[1]) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(JWTPayload.self, from: payloadData)
        } catch {
            print("❌ JWT 디코딩 실패:", error)
            return nil
        }
    }
    
    private static func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // 패딩 추가
        while base64.count % 4 != 0 {
            base64 += "="
        }
        
        return Data(base64Encoded: base64)
    }
} 