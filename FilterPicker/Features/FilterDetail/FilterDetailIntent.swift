//
//  FilterDetailIntent.swift
//  FilterPicker
//
//  Created by 조다은 on 6/1/25.
//

import Foundation

enum FilterDetailIntent {
    case loadFilterDetail(filterId: String)
    case toggleLike(filterId: String)
    case refresh(filterId: String)
    case loadAddress(latitude: Double, longitude: Double)
} 