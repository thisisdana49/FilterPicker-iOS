import Foundation
import SwiftUI
import UIKit

@MainActor
final class MyPageStore: ObservableObject {
    @Published private(set) var state: MyPageState
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.state = MyPageState()
        self.userRepository = userRepository
        
        Task {
            await dispatch(.fetchProfile)
        }
    }
    
    func dispatch(_ intent: MyPageIntent) {
        switch intent {
        case .fetchProfile:
            Task {
                do {
                    let profile = try await userRepository.fetchMyProfile()
                    print("📦 [Response] UserProfile:", profile)
                    
                    // 상태 업데이트
                    state = MyPageState(
                        userId: profile.userId,
                        email: profile.email,
                        nick: profile.nick,
                        hashTags: profile.hashTags,
                        name: profile.name ?? "",
                        introduction: profile.introduction ?? "",
                        profileImageURL: profile.profileImage,
                        phoneNum: profile.phoneNum ?? "",
                        isLoading: false
                    )
                    
                    // 프로필 이미지가 있는 경우 로드
                    if let imageURL = profile.profileImage {
                        loadProfileImage(from: imageURL)
                    }
                    
                    print("🔄 [State] Profile fetched:", state.nick, state.email, state.profileImageURL)
                } catch {
                    print("❌ [Error] Failed to fetch profile:", error)
                    state.error = error
                    state.isLoading = false
                }
            }
            
        case .updateName(let name):
            state.name = name
            
        case .updateNick(let nick):
            state.nick = nick
            
        case .updateIntroduction(let introduction):
            state.introduction = introduction
            
        case .updatePhoneNum(let phoneNum):
            state.phoneNum = phoneNum
            
        case .uploadProfileImage(let imageData):
            Task {
                do {
                    state.isUploadingImage = true
                    let response = try await userRepository.uploadProfileImage(imageData)
                    state.profileImageURL = "" /*response.imageUrl*/
                    if let image = UIImage(data: imageData) {
                        state.profileImage = image
                    }
                    state.isUploadingImage = false
                } catch {
                    print("❌ [Error] Failed to upload image:", error)
                    state.uploadError = error
                    state.isUploadingImage = false
                }
            }
            
        case .addHashTag(let tag):
            if !state.hashTags.contains(tag) {
                state.hashTags.append(tag)
            }
            
        case .removeHashTag(let tag):
            state.hashTags.removeAll { $0 == tag }
            
        case .saveProfile:
            Task {
                do {
                    state.isSaving = true
                    let request = EditProfileRequest(
                        name: state.name,
                        introduction: state.introduction,
                        profileImage: state.profileImageURL,
                        phoneNum: state.phoneNum,
                        hashTags: state.hashTags
                    )
                    try await userRepository.updateMyProfile(request)
                    state.isSaving = false
                } catch {
                    print("❌ [Error] Failed to save profile:", error)
                    state.error = error
                    state.isSaving = false
                }
            }
            
        case .logout:
            // TODO: 로그아웃 처리
            break
        case .startEditing:
            break
        case .cancelEditing:
            break
        case .updateProfileImageURL(_):
            break
        }
    }
    
    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    state.profileImage = image
                }
            } catch {
                print("❌ [Error] Failed to load profile image:", error)
            }
        }
    }
} 
