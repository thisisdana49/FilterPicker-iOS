//
//  FilterFeedIntent.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

enum FilterFeedIntent: Equatable {
  // MARK: - Top Ranking
  case loadTopRanking
  case changeRankingType(FilterRankingType)
  
  // MARK: - Filter Feed
  case loadFilters
  case loadMoreFilters
  case refreshFilters
  
  // MARK: - Filter Actions
  case toggleLike(String) // filterId
  case filterTapped(String) // filterId
  
  // MARK: - State Preservation
  case saveScrollPosition(Int) // lastViewedIndex
  case markReturnedFromDetail
  case resetViewState
  
  // MARK: - Error Handling
  case clearError
} 