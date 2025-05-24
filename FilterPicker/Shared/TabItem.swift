import Foundation

/// 앱 하단 탭바의 각 탭 항목을 정의합니다.
enum TabItem: Int, CaseIterable, Identifiable {
  case home
  case feed
  case filter
  case search
  case profile

  /// 고유 식별자
  var id: Int { rawValue }

  /// 탭 타이틀
  var title: String {
    switch self {
    case .home: return "홈"
    case .feed: return "피드"
    case .filter: return "필터"
    case .search: return "검색"
    case .profile: return "마이"
    }
  }

  /// 탭 아이콘(Asset 이미지 이름)
  var iconAssetName: String {
    switch self {
    case .home: return "tab_home"
    case .feed: return "tab_feed"
    case .filter: return "tab_filter"
    case .search: return "tab_search"
    case .profile: return "tab_profile"
    }
  }
} 