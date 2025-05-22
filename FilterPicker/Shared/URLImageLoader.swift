//
//  URLImageLoader.swift
//  FilterPicker
//
//  Created by 조다은 on 5/21/25.
//

import SwiftUI
import Combine

class URLImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?

    func load(from url: URL) {
        var request = URLRequest(url: url)
        request.setValue(AppConfig.apiKey, forHTTPHeaderField: "SesacKey")
        if let accessToken = TokenStorage.accessToken, !TokenStorage.isAccessTokenExpired() {
            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }

    func cancel() {
        cancellable?.cancel()
    }
} 
