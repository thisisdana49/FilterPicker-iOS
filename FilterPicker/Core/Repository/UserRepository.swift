import Foundation

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

class UserRepository {
    private let baseURL = "https://api.example.com" // 실제 API 엔드포인트로 변경 필요
    
    func fetchMyProfile() async throws -> UserProfileResponse {
        guard let url = URL(string: "\(baseURL)/users/me") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(UserProfileResponse.self, from: data)
    }
    
    func updateMyProfile(_ request: EditProfileRequest) async throws {
        guard let url = URL(string: "\(baseURL)/users/me") else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func uploadProfileImage(_ imageData: Data) async throws -> String {
        guard let url = URL(string: "\(baseURL)/users/me/profile-image") else {
            throw URLError(.badURL)
        }
        
        let boundary = UUID().uuidString
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        struct ImageUploadResponse: Codable {
            let imageURL: String
        }
        
        let uploadResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
        return uploadResponse.imageURL
    }
} 