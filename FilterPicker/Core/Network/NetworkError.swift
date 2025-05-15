//
//  NetworkError.swift
//  FilterPicker
//
//  Created by 조다은 on 5/15/25.
//

import Foundation

enum NetworkError: Error {
    case invalidRequest
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)
}
