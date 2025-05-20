//
//  FontStyle.swift
//  FilterPicker
//
//  Created by 조다은 on 5/18/25.
//

import Foundation
import SwiftUI

enum FontStyle {
    // Base: Pretendard
    case title1         // 20, bold
    case body1          // 16, medium
    case body2          // 14, medium
    case body3          // 13, medium
    case caption1       // 12, regular
    case caption2       // 10, regular
    case caption3       // 8, regular

    // Point: Mulgyeol
    case mulgyeolTitle1 // 32, bold
    case mulgyeolBody1  // 20, regular
    case mulgyeolCaption1 // 14, regular

    var font: Font {
        switch self {
        // MARK: - Pretendard
        case .title1:
            return .custom(CustomFontName.pretendardBold, size: 20)
        case .body1:
            return .custom(CustomFontName.pretendardMedium, size: 16)
        case .body2:
            return .custom(CustomFontName.pretendardMedium, size: 14)
        case .body3:
            return .custom(CustomFontName.pretendardMedium, size: 13)
        case .caption1:
            return .custom(CustomFontName.pretendardRegular, size: 12)
        case .caption2:
            return .custom(CustomFontName.pretendardRegular, size: 10)
        case .caption3:
            return .custom(CustomFontName.pretendardRegular, size: 8)

        // MARK: - Mulgyeol
        case .mulgyeolTitle1:
            return .custom(CustomFontName.mulgyeolBold, size: 32)
        case .mulgyeolBody1:
            return .custom(CustomFontName.mulgyeolRegular, size: 20)
        case .mulgyeolCaption1:
            return .custom(CustomFontName.mulgyeolRegular, size: 14)
        }
    }
}
