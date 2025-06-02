//
//  GeocodingRepository.swift
//  FilterPicker
//
//  Created by 조다은 on 6/2/25.
//

import Foundation
import CoreLocation

// MARK: - Repository Protocol
protocol GeocodingRepositoryProtocol {
    func getAddress(latitude: Double, longitude: Double) async throws -> AddressInfo
}

// MARK: - Apple MapKit Implementation
class AppleGeocodingRepository: GeocodingRepositoryProtocol {
    private let geocoder = CLGeocoder()
    private let cache = NSCache<NSString, AddressInfo>()
    
    func getAddress(latitude: Double, longitude: Double) async throws -> AddressInfo {
        let cacheKey = "\(latitude),\(longitude)" as NSString
        
        // 캐시 확인
        if let cachedAddress = cache.object(forKey: cacheKey) {
            return cachedAddress
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                if let error = error {
                    continuation.resume(throwing: GeocodingError.networkError(error))
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    continuation.resume(throwing: GeocodingError.noResultFound)
                    return
                }
                
                let addressInfo = self?.convertToAddressInfo(placemark) ?? AddressInfo(
                    formattedAddress: "주소를 찾을 수 없습니다",
                    locality: nil,
                    subLocality: nil,
                    thoroughfare: nil,
                    subThoroughfare: nil,
                    country: nil,
                    countryCode: nil
                )
                
                // 캐시에 저장
                self?.cache.setObject(addressInfo, forKey: cacheKey)
                
                continuation.resume(returning: addressInfo)
            }
        }
    }
    
    private func convertToAddressInfo(_ placemark: CLPlacemark) -> AddressInfo {
        // 디버깅을 위한 모든 프로퍼티 출력
        print("🗺️ CLPlacemark 프로퍼티 분석:")
        print("   name: \(placemark.name ?? "nil")")
        print("   country: \(placemark.country ?? "nil")")
        print("   administrativeArea: \(placemark.administrativeArea ?? "nil")")
        print("   subAdministrativeArea: \(placemark.subAdministrativeArea ?? "nil")")
        print("   locality: \(placemark.locality ?? "nil")")
        print("   subLocality: \(placemark.subLocality ?? "nil")")
        print("   thoroughfare: \(placemark.thoroughfare ?? "nil")")
        print("   subThoroughfare: \(placemark.subThoroughfare ?? "nil")")
        print("   postalCode: \(placemark.postalCode ?? "nil")")
        print("   isoCountryCode: \(placemark.isoCountryCode ?? "nil")")
        if let areasOfInterest = placemark.areasOfInterest {
            print("   areasOfInterest: \(areasOfInterest)")
        }
        print("---")
        
        // 도로명 주소 형식으로 포맷팅 (예: "서울 영등포구 선유로 9길 30")
        var formattedComponents: [String] = []
        
        if let country = placemark.country, country == "대한민국" || country == "South Korea" {
            // 한국 주소 포맷팅 (중복 제거)
            
            // 1. 시/도 (짧은 형태로)
            var cityProvince: String?
            if let administrativeArea = placemark.administrativeArea {
                cityProvince = administrativeArea
                    .replacingOccurrences(of: "특별시", with: "")
                    .replacingOccurrences(of: "광역시", with: "")
                    .replacingOccurrences(of: "특별자치시", with: "")
                    .replacingOccurrences(of: "특별자치도", with: "")
                    .replacingOccurrences(of: "도", with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
            
            // 2. 구/군 찾기 (subAdministrativeArea 우선, 없으면 locality에서 구/군만)
            var district: String?
            if let subAdministrativeArea = placemark.subAdministrativeArea {
                district = subAdministrativeArea
            } else if let locality = placemark.locality, 
                      locality != placemark.administrativeArea, // 시/도와 다른 경우만
                      (locality.contains("구") || locality.contains("군") || locality.contains("시")) {
                district = locality
            }
            
            // 3. 동/면 또는 도로명 (중복 제거)
            var streetOrDistrict: String?
            if let thoroughfare = placemark.thoroughfare,
               thoroughfare != placemark.subLocality { // subLocality와 다른 경우 도로명으로 사용
                streetOrDistrict = thoroughfare
            } else if let subLocality = placemark.subLocality {
                streetOrDistrict = subLocality
            }
            
            // 4. 번지
            var houseNumber: String?
            if let subThoroughfare = placemark.subThoroughfare {
                houseNumber = subThoroughfare
            }
            
            // 중복 제거하면서 구성요소 추가
            if let cityProvince = cityProvince, !cityProvince.isEmpty {
                formattedComponents.append(cityProvince)
            }
            
            if let district = district, !district.isEmpty,
               district != cityProvince { // 시/도와 중복되지 않는 경우만
                formattedComponents.append(district)
            }
            
            if let streetOrDistrict = streetOrDistrict, !streetOrDistrict.isEmpty,
               streetOrDistrict != district, // 구/군과 중복되지 않는 경우만
               streetOrDistrict != cityProvince { // 시/도와 중복되지 않는 경우만
                formattedComponents.append(streetOrDistrict)
            }
            
            if let houseNumber = houseNumber, !houseNumber.isEmpty {
                formattedComponents.append(houseNumber)
            }
            
            print("🏠 중복 제거 후 포맷팅 결과: \(formattedComponents.joined(separator: " "))")
            
            // 주소가 너무 짧으면 name 사용
            if formattedComponents.count < 2, let name = placemark.name {
                let cleanName = name
                    .replacingOccurrences(of: "대한민국", with: "")
                    .replacingOccurrences(of: "South Korea", with: "")
                    .trimmingCharacters(in: .whitespaces)
                print("🏠 Fallback name 사용: \(cleanName)")
                return AddressInfo(
                    formattedAddress: cleanName,
                    locality: placemark.locality,
                    subLocality: placemark.subLocality,
                    thoroughfare: placemark.thoroughfare,
                    subThoroughfare: placemark.subThoroughfare,
                    country: placemark.country,
                    countryCode: placemark.isoCountryCode
                )
            }
        } else {
            // 해외 주소
            if let name = placemark.name { formattedComponents.append(name) }
            if let locality = placemark.locality { formattedComponents.append(locality) }
            if let country = placemark.country { formattedComponents.append(country) }
        }
        
        return AddressInfo(
            formattedAddress: formattedComponents.joined(separator: " "),
            locality: placemark.locality,
            subLocality: placemark.subLocality,
            thoroughfare: placemark.thoroughfare,
            subThoroughfare: placemark.subThoroughfare,
            country: placemark.country,
            countryCode: placemark.isoCountryCode
        )
    }
}

// MARK: - Geocoding Errors
enum GeocodingError: LocalizedError {
    case networkError(Error)
    case noResultFound
    case invalidCoordinates
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .noResultFound:
            return "주소를 찾을 수 없습니다"
        case .invalidCoordinates:
            return "잘못된 좌표입니다"
        }
    }
} 