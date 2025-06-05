//
//  UserModels.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

// MARK: - Creator Model
struct Creator: Codable, Equatable {
  let userId: String
  let nick: String
  let name: String
  let introduction: String
  let profileImage: String?
  let hashTags: [String]
  
  // UI에서 사용하기 위한 computed properties
  /// 프로필 이미지 URL
  var profileImageURL: String {
    guard let profileImage = profileImage else { return "" }
    return AppConfig.baseURL + "/v1/" + profileImage
  }
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case nick
    case name
    case introduction
    case profileImage
    case hashTags
  }
  
  // 일반 이니셜라이저 (MockData 등에서 직접 생성용)
  init(
    userId: String,
    nick: String,
    name: String,
    introduction: String,
    profileImage: String?,
    hashTags: [String]
  ) {
    self.userId = userId
    self.nick = nick
    self.name = name
    self.introduction = introduction
    self.profileImage = profileImage
    self.hashTags = hashTags
  }
  
  // 커스텀 디코딩 - profileImage가 없을 때 기본값 처리
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    do {
      // 모든 키 먼저 확인
      let allKeys = container.allKeys.map { $0.stringValue }
      print("🔍 Available keys in Creator: \(allKeys)")
      
      userId = try container.decode(String.self, forKey: .userId)
      print("✅ Creator userId decoded: \(userId)")
      
      // nick - 키 존재 여부 확인 후 안전하게 디코딩
      if container.contains(.nick) {
        nick = (try? container.decode(String.self, forKey: .nick)) ?? ""
        print("✅ Creator nick decoded: '\(nick)'")
      } else {
        nick = ""
        print("⚠️ Creator nick key not found, setting to empty string")
      }
      
      // name - 키 존재 여부 확인 후 안전하게 디코딩
      if container.contains(.name) {
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        print("✅ Creator name decoded: '\(name)'")
      } else {
        name = ""
        print("⚠️ Creator name key not found, setting to empty string")
      }
      
      // introduction - 키 존재 여부 확인 후 안전하게 디코딩
      if container.contains(.introduction) {
        introduction = (try? container.decode(String.self, forKey: .introduction)) ?? ""
        print("✅ Creator introduction decoded: '\(introduction)'")
      } else {
        introduction = ""
        print("⚠️ Creator introduction key not found, setting to empty string")
      }
      
      // profileImage는 더 안전하게 처리
      if container.contains(.profileImage) {
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        print("✅ Creator profileImage decoded: \(profileImage ?? "nil")")
      } else {
        profileImage = nil
        print("⚠️ Creator profileImage key not found, setting to nil")
      }
      
      // hashTags - 키 존재 여부 확인 후 안전하게 디코딩
      if container.contains(.hashTags) {
        hashTags = (try? container.decode([String].self, forKey: .hashTags)) ?? []
        print("✅ Creator hashTags decoded: \(hashTags)")
      } else {
        hashTags = []
        print("⚠️ Creator hashTags key not found, setting to empty array")
      }
      
    } catch {
      print("❌ Creator decoding error: \(error)")
      throw error
    }
  }
} 