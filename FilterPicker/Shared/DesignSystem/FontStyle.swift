//
//  FontStyle.swift
//  FilterPicker
//
//  Created by 조다은 on 5/18/25.
//

import Foundation
import SwiftUI

enum FontStyle {
    case title1
    case body1
    case body2
    case body3
    case caption1
    case caption2
    case caption3
    
    var font: Font {
        switch self {
        case .title1: return .system(size: 20, weight: .bold)
        case .body1: return .system(size: 16, weight: .regular)
        case .body2: return .system(size: 14, weight: .regular)
        case .body3: return .system(size: 13, weight: .medium)
        case .caption1: return .system(size: 12, weight: .regular)
        case .caption2: return .system(size: 10, weight: .regular)
        case .caption3: return .system(size: 8, weight: .regular)
        }
    }
}

