import Foundation

protocol UserRepositoryProtocol {
    func fetchMyProfile() async throws -> UserProfileResponse
    func updateMyProfile(_ request: EditProfileRequest) async throws
    func uploadProfileImage(_ imageData: Data) async throws -> String
}

final class UserRepository: UserRepositoryProtocol {
    private let apiService: APIService
    
    init(apiService: APIService = DefaultAPIService()) {
        self.apiService = apiService
    }
    
    func fetchMyProfile() async throws -> UserProfileResponse {
        let request = APIRequest(
            path: "/v1/users/me/profile",
            method: .get
        )
        
        print("🌐 [Request] GET /v1/users/me/profile")
        do {
            let response: UserProfileResponse = try await apiService.request(request)
            print("📦 [Response] UserProfile: \(response)")
            return response
        } catch {
            print("❌ [Error] UserProfile: \(error)")
            throw error
        }
    }
    
    func updateMyProfile(_ request: EditProfileRequest) async throws {
        let apiRequest = APIRequest(
            path: "/v1/users/me/profile",
            method: .put,
            body: request
        )
        
        print("🌐 [Request] PUT /v1/users/me/profile")
        do {
            try await apiService.request(apiRequest)
            print("✅ [Response] Profile updated successfully")
        } catch {
            print("❌ [Error] Profile update failed: \(error)")
            throw error
        }
    }
    
    func uploadProfileImage(_ imageData: Data) async throws -> String {
        let boundary = UUID().uuidString
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        let request = APIRequest(
            path: "/v1/users/profile/image",
            method: .post,
            headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"],
            body: body
        )
        
        print("🌐 [Request] POST /v1/users/profile/image")
        do {
            let response: ImageUploadResponse = try await apiService.request(request)
            print("📦 [Response] Image uploaded successfully: \(response.imageURL)")
            return response.imageURL
        } catch {
            print("❌ [Error] Image upload failed: \(error)")
            throw error
        }
    }
}

// 임시 모델 (실제 API 응답에 맞게 수정 필요)
struct UserProfileResponse: Codable {
    let id: String
    let name: String
    let bio: String
    let profileImageURL: String?
}

struct EditProfileRequest: Codable {
    let name: String
    let bio: String
    let profileImageURL: String?
}

struct ImageUploadResponse: Codable {
    let imageURL: String
} 