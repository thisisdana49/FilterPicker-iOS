//
//  TabItem.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

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

  /// 탭 아이콘(Asset 이미지 이름) - 선택 상태에 따라 다름
  func iconAssetName(isSelected: Bool) -> String {
    switch self {
    case .home: return isSelected ? "IconMain_Fill" : "IconMain_Empty"
    case .feed: return isSelected ? "IconFeed_Fill" : "IconFeed_Empty"
    case .filter: return isSelected ? "IconFilter_Fill" : "IconFilter_Empty"
    case .search: return isSelected ? "IconSearch_Fill" : "IconSearch_Empty"
    case .profile: return isSelected ? "IconProfile_Fill" : "IconProfile_Empty"
    }
  }
} 
