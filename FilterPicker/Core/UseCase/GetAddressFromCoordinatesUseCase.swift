//
//  GetAddressFromCoordinatesUseCase.swift
//  FilterPicker
//
//  Created by 조다은 on 6/2/25.
//

import Foundation

class GetAddressFromCoordinatesUseCase {
    private let geocodingRepository: GeocodingRepositoryProtocol
    
    init(geocodingRepository: GeocodingRepositoryProtocol = AppleGeocodingRepository()) {
        self.geocodingRepository = geocodingRepository
    }
    
    func execute(latitude: Double, longitude: Double) async throws -> AddressInfo {
        // 좌표 유효성 검사
        guard latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180 else {
            throw GeocodingError.invalidCoordinates
        }
        
        return try await geocodingRepository.getAddress(latitude: latitude, longitude: longitude)
    }
} 