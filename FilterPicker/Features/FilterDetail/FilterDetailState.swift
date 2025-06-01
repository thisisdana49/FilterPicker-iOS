//
//  FilterDetailState.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

struct FilterDetailState: Equatable {
    var filterDetail: FilterDetailResponse?
    var isLoading: Bool = false
    var error: Error?
    var isLikeLoading: Bool = false
    
    static func == (lhs: FilterDetailState, rhs: FilterDetailState) -> Bool {
        return lhs.filterDetail?.filterId == rhs.filterDetail?.filterId &&
               lhs.isLoading == rhs.isLoading &&
               lhs.isLikeLoading == rhs.isLikeLoading &&
               lhs.error?.localizedDescription == rhs.error?.localizedDescription
    }
} 