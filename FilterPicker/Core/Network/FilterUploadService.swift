//
//  FilterUploadService.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import Foundation
import UIKit

// MARK: - Request Models

struct ImageUploadRequest {
    let filteredImageData: Data
    let originalImageData: Data
}

struct FilterCreateRequest: Codable {
    let category: String
    let title: String
    let price: Int
    let description: String
    let files: [String]
    let photoMetadata: PhotoMetadata
    let filterValues: FilterValues
    
    private enum CodingKeys: String, CodingKey {
        case category, title, price, description, files
        case photoMetadata = "photo_metadata"
        case filterValues = "filter_values"
    }
}

struct FilterValues: Codable {
    let brightness: Float
    let exposure: Float
    let contrast: Float
    let saturation: Float
    let sharpness: Float
    let blur: Float
    let vignette: Float
    let noiseReduction: Float
    let highlights: Float
    let shadows: Float
    let temperature: Float
    let blackPoint: Float
    
    private enum CodingKeys: String, CodingKey {
        case brightness, exposure, contrast, saturation, sharpness, blur, vignette
        case noiseReduction = "noise_reduction"
        case highlights, shadows, temperature
        case blackPoint = "black_point"
    }
}

// MARK: - Response Models

struct FilterImagesUploadResponse: Codable {
    let files: [String]
}

struct FilterCreateResponse: Codable {
    let success: Bool?
    let message: String?
}

// MARK: - Filter Upload Service Protocol

protocol FilterUploadService {
    func uploadFilter(uploadData: UploadImageData, filterInfo: FilterCreateRequest) async throws -> FilterCreateResponse
}

// MARK: - Default Filter Upload Service

final class DefaultFilterUploadService: FilterUploadService {
    
    private let apiService: APIService
    
    init(apiService: APIService = DefaultAPIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Public Methods
    
    /// 2단계 필터 업로드 (이미지 업로드 → 필터 생성)
    func uploadFilter(uploadData: UploadImageData, filterInfo: FilterCreateRequest) async throws -> FilterCreateResponse {
        print("🚀 2단계 필터 업로드 시작...")
        
        // 1단계: 이미지 파일 업로드
        let imageResponse = try await uploadImages(uploadData: uploadData)
        print("✅ 1단계 완료: 이미지 업로드 성공")
        print("  - 업로드된 파일: \(imageResponse.files)")
        
        // 2단계: 필터 정보 생성
        let filterResponse = try await createFilter(filterInfo: filterInfo, uploadedFiles: imageResponse.files)
        print("✅ 2단계 완료: 필터 생성 성공")
        
        return filterResponse
    }
    
    // MARK: - Private Methods
    
    /// 1단계: 이미지 파일 업로드
    private func uploadImages(uploadData: UploadImageData) async throws -> FilterImagesUploadResponse {
        print("📤 1단계: 이미지 업로드 요청 중...")
        print("  - 엔드포인트: POST /v1/filters/files")
        print("  - 필터 이미지: \(uploadData.filteredImageData.count) bytes")
        print("  - 원본 이미지: \(uploadData.originalImageData.count) bytes")
        
        guard let url = URL(string: AppConfig.baseURL + "/v1/filters/files") else {
            throw FilterUploadError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 기존 패턴과 동일한 인증 헤더 추가
        request.setValue(AppConfig.apiKey, forHTTPHeaderField: "SesacKey")
        if let accessToken = TokenStorage.accessToken, !TokenStorage.isAccessTokenExpired() {
            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Multipart form data 생성
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = createMultipartBody(
            boundary: boundary,
            filteredImageData: uploadData.filteredImageData,
            originalImageData: uploadData.originalImageData
        )
        
        request.httpBody = httpBody
        
        // CURL 로그 출력 (기존 패턴과 동일)
        print("🐚 [CURL] \(request.curlString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FilterUploadError.invalidResponse
            }
            
            // 응답 로깅 (기존 패턴과 동일)
            print("📬 [Response] Status: \(httpResponse.statusCode)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Data: \(jsonString)")
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw FilterUploadError.serverError(httpResponse.statusCode)
            }
            
            let imageResponse = try JSONDecoder().decode(FilterImagesUploadResponse.self, from: data)
            return imageResponse
            
        } catch let error as FilterUploadError {
            throw error
        } catch {
            throw FilterUploadError.networkError(error)
        }
    }
    
    /// 2단계: 필터 정보 생성 (기존 APIService 패턴 사용)
    private func createFilter(filterInfo: FilterCreateRequest, uploadedFiles: [String]) async throws -> FilterCreateResponse {
        print("📤 2단계: 필터 생성 요청 중...")
        print("  - 엔드포인트: POST /v1/filters")
        print("  - 카테고리: \(filterInfo.category)")
        print("  - 제목: \(filterInfo.title)")
        print("  - 가격: \(filterInfo.price)원")
        print("  - 파일 경로: \(uploadedFiles)")
        
        // 업로드된 파일 경로를 포함한 요청 생성
        let updatedFilterInfo = FilterCreateRequest(
            category: filterInfo.category,
            title: filterInfo.title,
            price: filterInfo.price,
            description: filterInfo.description,
            files: uploadedFiles,  // 1단계에서 받은 파일 경로들
            photoMetadata: filterInfo.photoMetadata,
            filterValues: filterInfo.filterValues
        )
        
        // FilterCreateRequest를 Dictionary로 변환
        guard let bodyDict = updatedFilterInfo.asDictionary() else {
            throw FilterUploadError.encodingError(NSError(domain: "FilterUpload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request body encoding failed"]))
        }
        
        // 기존 APIService 패턴 사용
        let apiRequest = APIRequest(
            path: "/v1/filters",
            method: .post,
            body: bodyDict
        )
        
        do {
            let response: FilterCreateResponse = try await apiService.request(apiRequest)
            return response
        } catch let networkError as NetworkError {
            // NetworkError를 FilterUploadError로 변환
            throw FilterUploadError.from(networkError)
        } catch {
            throw FilterUploadError.networkError(error)
        }
    }
    
    /// Multipart form data 생성
    private func createMultipartBody(
        boundary: String,
        filteredImageData: Data,
        originalImageData: Data
    ) -> Data {
        var body = Data()
        
        // 필터된 이미지 (애프터) - 첫 번째
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"files\"; filename=\"filtered.jpg\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(filteredImageData)
        body.appendString("\r\n")
        
        // 원본 이미지 (비포) - 두 번째
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"files\"; filename=\"original.jpg\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(originalImageData)
        body.appendString("\r\n")
        
        // 마무리
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
}

// MARK: - Error Types

enum FilterUploadError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
    case noData
    case encodingError(Error)
    case decodingError(Error)
    case compressionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .serverError(let code):
            return "서버 오류 (코드: \(code))"
        case .noData:
            return "응답 데이터가 없습니다."
        case .encodingError(let error):
            return "인코딩 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "디코딩 오류: \(error.localizedDescription)"
        case .compressionFailed:
            return "이미지 압축에 실패했습니다."
        }
    }
    
    // NetworkError를 FilterUploadError로 변환
    static func from(_ networkError: NetworkError) -> FilterUploadError {
        switch networkError {
        case .invalidRequest:
            return .invalidURL
        case .invalidResponse:
            return .invalidResponse
        case .statusCode(let code):
            return .serverError(code)
        case .decoding(let error):
            return .decodingError(error)
        case .tokenExpired, .refreshTokenFailed:
            return .serverError(401)
        }
    }
}

// MARK: - Extensions

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// FilterCreateRequest를 Dictionary로 변환하는 Extension
extension FilterCreateRequest {
    func asDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}

// URLRequest CURL Extension (기존 패턴과 동일)
extension URLRequest {
    var curlString: String {
        guard let url = self.url else { return "❌ Invalid URL" }
        
        var curlCommand = "curl -X \(self.httpMethod ?? "GET")"
        
        // URL 추가
        curlCommand += " '\(url.absoluteString)'"
        
        // 헤더 추가
        if let headers = self.allHTTPHeaderFields {
            for (key, value) in headers {
                curlCommand += " \\\n  -H '\(key): \(value)'"
            }
        }
        
        // Body 추가 (있는 경우)
        if let httpBody = self.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            curlCommand += " \\\n  -d '\(bodyString)'"
        }
        
        return curlCommand
    }
} 