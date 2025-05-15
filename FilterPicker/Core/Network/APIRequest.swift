//
//  APIRequest.swift
//  FilterPicker
//
//  Created by 조다은 on 5/13/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct APIRequest {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let queryParameters: [String: String]?
    let body: [String: Any]?

    init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        body: [String: Any]? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
    }
}
