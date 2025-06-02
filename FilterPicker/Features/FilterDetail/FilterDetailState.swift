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
    var addressInfo: AddressInfo?
    var isLoadingAddress: Bool = false
    var addressError: Error?
    
    static func == (lhs: FilterDetailState, rhs: FilterDetailState) -> Bool {
        return lhs.filterDetail?.filterId == rhs.filterDetail?.filterId &&
               lhs.isLoading == rhs.isLoading &&
               lhs.isLikeLoading == rhs.isLikeLoading &&
               lhs.isLoadingAddress == rhs.isLoadingAddress &&
               lhs.addressInfo?.formattedAddress == rhs.addressInfo?.formattedAddress &&
               lhs.error?.localizedDescription == rhs.error?.localizedDescription &&
               lhs.addressError?.localizedDescription == rhs.addressError?.localizedDescription
    }
} 