//
//  FilterEditIntent.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

enum FilterEditIntent {
    case setImage(UIImage)
    case selectParameter(FilterParameter)
    case updateParameterValue(Float)
    case startEditingParameter
    case resetAllValues
    case applyFilter
    case saveChanges
    case clearError
    case undo
    case redo
    case startComparing
    case stopComparing
} 