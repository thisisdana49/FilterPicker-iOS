//
//  UserRepositoryProtocol.swift
//  FilterPicker
//
//  Created by 조다은 on 5/25/25.
//

import Foundation

// MARK: - Response Types
struct EmptyResponse: Codable {}

// MARK: - Encodable Extension
extension Encodable {
    func asDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}

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
        let body = request.asDictionary()
        let apiRequest = APIRequest(
            path: "/v1/users/me/profile",
            method: .put,
            body: body
        )
        
        print("🌐 [Request] PUT /v1/users/me/profile")
        do {
            let _: EmptyResponse = try await apiService.request(apiRequest)
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
        
        // multipart/form-data 요청을 위한 별도의 URLRequest 생성
        var urlRequest = URLRequest(url: URL(string: AppConfig.baseURL + "/v1/users/profile/image")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(AppConfig.apiKey, forHTTPHeaderField: "SesacKey")
        if let accessToken = TokenStorage.accessToken,
           !TokenStorage.isAccessTokenExpired() {
            urlRequest.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.httpBody = body
        
        print("🌐 [Request] POST /v1/users/profile/image")
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }
            
            let imageResponse: ImageUploadResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
            print("📦 [Response] Image uploaded successfully: \(imageResponse.imageURL)")
            return imageResponse.imageURL
        } catch let error as NetworkError {
            print("❌ [Error] Image upload failed: \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ [Error] Image upload failed: \(error)")
            throw NetworkError.decoding(error)
        }
    }
}
