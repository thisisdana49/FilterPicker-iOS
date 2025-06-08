//
//  ImageCacheManager.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI
import Combine
import CryptoKit

// MARK: - Image Cache Configuration
struct ImageCacheConfig {
    static let memoryCapacity: Int = 50 * 1024 * 1024 // 50MB
    static let diskCapacity: Int = 100 * 1024 * 1024 // 100MB
    static let thumbnailSize: CGSize = CGSize(width: 300, height: 300)
    static let cacheDirectoryName = "ImageCache"
}

// MARK: - Image Cache Manager
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    // 메모리 캐시 (NSCache)
    private let memoryCache = NSCache<NSString, UIImage>()
    
    // 디스크 캐시 디렉토리
    private let diskCacheDirectory: URL
    
    // 현재 진행 중인 요청들 (중복 방지) - 스레드 안전성을 위한 동기화
    private var loadingTasks: [String: Task<UIImage?, Error>] = [:]
    private let taskQueue = DispatchQueue(label: "image.cache.tasks", attributes: .concurrent)
    private let loadingTasksLock = NSLock()
    
    private init() {
        // 메모리 캐시 설정
        memoryCache.totalCostLimit = ImageCacheConfig.memoryCapacity
        memoryCache.countLimit = 100 // 최대 100개 이미지
        
        // 디스크 캐시 디렉토리 설정
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheDirectory = cacheDirectory.appendingPathComponent(ImageCacheConfig.cacheDirectoryName)
        
        // 디렉토리 생성
        try? FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
        
        // 앱 시작 시 디스크 캐시 정리
        cleanupDiskCacheIfNeeded()
        
        print("📦 [ImageCache] 초기화 완료")
        print("    - 메모리 제한: \(ImageCacheConfig.memoryCapacity / 1024 / 1024)MB")
        print("    - 디스크 제한: \(ImageCacheConfig.diskCapacity / 1024 / 1024)MB")
        print("    - 캐시 디렉토리: \(diskCacheDirectory.path)")
    }
    
    // MARK: - Public Methods
    
    func loadImage(from url: URL) async -> UIImage? {
        let cacheKey = generateCacheKey(for: url)
        
        // 1. 메모리 캐시 확인
        if let cachedImage = memoryCache.object(forKey: cacheKey as NSString) {
            print("🎯 [ImageCache] 메모리 캐시 히트: \(url.lastPathComponent)")
            return cachedImage
        }
        
        // 2. 디스크 캐시 확인
        if let diskImage = loadFromDiskCache(key: cacheKey) {
            print("💾 [ImageCache] 디스크 캐시 히트: \(url.lastPathComponent)")
            // 메모리 캐시에도 저장
            memoryCache.setObject(diskImage, forKey: cacheKey as NSString)
            return diskImage
        }
        
        // 3. 중복 요청 방지 및 네트워크 요청
        return await withCheckedContinuation { continuation in
            // 스레드 안전한 딕셔너리 접근
            loadingTasksLock.lock()
            let existingTask = loadingTasks[cacheKey]
            loadingTasksLock.unlock()
            
            if let existingTask = existingTask {
                print("⏳ [ImageCache] 기존 요청 대기: \(url.lastPathComponent)")
                
                // 기존 작업의 결과를 기다림
                Task {
                    let result = try? await existingTask.value
                    continuation.resume(returning: result)
                }
            } else {
                print("🌐 [ImageCache] 새로운 네트워크 요청 시작: \(url.lastPathComponent)")
                
                // 새로운 작업 생성
                let newTask = Task<UIImage?, Error> {
                    defer {
                        self.loadingTasksLock.lock()
                        self.loadingTasks.removeValue(forKey: cacheKey)
                        self.loadingTasksLock.unlock()
                    }
                    
                    return await self.downloadImage(from: url, cacheKey: cacheKey)
                }
                
                // 작업 등록 (스레드 안전)
                loadingTasksLock.lock()
                loadingTasks[cacheKey] = newTask
                loadingTasksLock.unlock()
                
                // 새 작업의 결과를 기다림
                Task {
                    let result = try? await newTask.value
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func downloadImage(from url: URL, cacheKey: String) async -> UIImage? {
        do {
            var request = URLRequest(url: url)
            request.setValue(AppConfig.apiKey, forHTTPHeaderField: "SesacKey")
            if let accessToken = TokenStorage.accessToken, !TokenStorage.isAccessTokenExpired() {
                request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let originalImage = UIImage(data: data) else {
                print("❌ [ImageCache] 다운로드 실패: \(url.lastPathComponent)")
                return nil
            }
            
            // 썸네일 생성 (메모리 절약)
            let thumbnailImage = createThumbnail(from: originalImage)
            
            // 캐시에 저장
            saveToCaches(image: thumbnailImage, key: cacheKey)
            
            print("✅ [ImageCache] 다운로드 완료: \(url.lastPathComponent)")
            return thumbnailImage
            
        } catch {
            print("❌ [ImageCache] 네트워크 오류: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createThumbnail(from image: UIImage) -> UIImage {
        let maxSize = max(ImageCacheConfig.thumbnailSize.width, ImageCacheConfig.thumbnailSize.height)
        
        let originalSize = image.size
        let aspectRatio = originalSize.width / originalSize.height
        
        let newSize: CGSize
        if originalSize.width > originalSize.height {
            // 가로가 더 긴 경우
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            // 세로가 더 긴 경우
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    private func saveToCaches(image: UIImage, key: String) {
        // 메모리 캐시에 저장
        memoryCache.setObject(image, forKey: key as NSString)
        
        // 디스크 캐시에 저장
        Task.detached(priority: .background) {
            await self.saveToDiskCache(image: image, key: key)
        }
    }
    
    private func saveToDiskCache(image: UIImage, key: String) async {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = diskCacheDirectory.appendingPathComponent(key)
        
        do {
            try data.write(to: fileURL)
            print("💾 [ImageCache] 디스크 저장 완료: \(key)")
        } catch {
            print("❌ [ImageCache] 디스크 저장 실패: \(error.localizedDescription)")
        }
    }
    
    private func loadFromDiskCache(key: String) -> UIImage? {
        let fileURL = diskCacheDirectory.appendingPathComponent(key)
        
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // 파일 접근 시간 업데이트 (LRU)
        try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
        
        return image
    }
    
    private func generateCacheKey(for url: URL) -> String {
        // URL을 해시화하여 파일명으로 사용
        let data = url.absoluteString.data(using: .utf8)!
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func cleanupDiskCacheIfNeeded() {
        Task.detached(priority: .background) {
            await self.performDiskCacheCleanup()
        }
    }
    
    private func performDiskCacheCleanup() async {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: diskCacheDirectory,
                includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
            )
            
            var totalSize: Int64 = 0
            var fileInfos: [(url: URL, size: Int64, date: Date)] = []
            
            // 파일 정보 수집
            for fileURL in fileURLs {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                let size = Int64(resourceValues.fileSize ?? 0)
                let date = resourceValues.contentModificationDate ?? Date.distantPast
                
                totalSize += size
                fileInfos.append((url: fileURL, size: size, date: date))
            }
            
            print("📊 [ImageCache] 디스크 캐시 현황: \(fileInfos.count)개 파일, \(totalSize / 1024 / 1024)MB")
            
            // 용량 초과 시 LRU 정책으로 삭제
            if totalSize > ImageCacheConfig.diskCapacity {
                // 수정 날짜 기준 오름차순 정렬 (오래된 것부터)
                fileInfos.sort { $0.date < $1.date }
                
                var deletedSize: Int64 = 0
                let targetSize = Int64(Double(ImageCacheConfig.diskCapacity) * 0.8) // 80%까지 줄이기
                
                for fileInfo in fileInfos {
                    if totalSize - deletedSize <= targetSize { break }
                    
                    try? FileManager.default.removeItem(at: fileInfo.url)
                    deletedSize += fileInfo.size
                }
                
                print("🗑️ [ImageCache] 디스크 캐시 정리 완료: \(deletedSize / 1024 / 1024)MB 삭제")
            }
            
        } catch {
            print("❌ [ImageCache] 디스크 캐시 정리 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Cache Management
    
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
        print("🧹 [ImageCache] 메모리 캐시 정리 완료")
    }
    
    func clearDiskCache() async {
        do {
            try FileManager.default.removeItem(at: diskCacheDirectory)
            try FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
            print("🧹 [ImageCache] 디스크 캐시 정리 완료")
        } catch {
            print("❌ [ImageCache] 디스크 캐시 정리 실패: \(error.localizedDescription)")
        }
    }
    
    func clearAllCaches() async {
        clearMemoryCache()
        await clearDiskCache()
    }
    
    // MARK: - App Lifecycle Management
    
    func handleMemoryWarning() {
        // 메모리 경고 시 메모리 캐시의 일부만 정리
        let currentCount = memoryCache.countLimit
        memoryCache.countLimit = max(10, currentCount / 2) // 절반으로 줄이기
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.memoryCache.countLimit = currentCount // 원래대로 복구
        }
        
        print("⚠️ [ImageCache] 메모리 경고 처리: 캐시 제한 임시 감소")
    }
    
    func handleAppDidEnterBackground() {
        // 백그라운드 진입 시 메모리 캐시 일부 정리
        let objectsToRemove = max(1, memoryCache.countLimit / 4) // 25% 정리
        
        // 임시로 제한을 줄여서 자동 정리 유도
        let originalLimit = memoryCache.countLimit
        memoryCache.countLimit = memoryCache.countLimit - objectsToRemove
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.memoryCache.countLimit = originalLimit
        }
        
        print("📱 [ImageCache] 백그라운드 진입: 메모리 캐시 일부 정리")
    }
    
    func handleAppWillTerminate() {
        // 앱 종료 시 진행 중인 작업들 정리 (스레드 안전)
        loadingTasksLock.lock()
        let tasks = Array(loadingTasks.values)
        loadingTasks.removeAll()
        loadingTasksLock.unlock()
        
        // 작업들 취소
        for task in tasks {
            task.cancel()
        }
        
        print("🛑 [ImageCache] 앱 종료: 진행 중인 작업들 정리 완료")
    }
    
    // MARK: - Cache Statistics
    
    func getCacheStatistics() -> ImageCacheStatistics {
        let memoryCount = memoryCache.countLimit
        
        var diskCount = 0
        var diskSize: Int64 = 0
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: diskCacheDirectory,
                includingPropertiesForKeys: [.fileSizeKey]
            )
            
            diskCount = fileURLs.count
            
            for fileURL in fileURLs {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let size = resourceValues.fileSize {
                    diskSize += Int64(size)
                }
            }
        } catch {
            print("❌ [ImageCache] 통계 조회 실패: \(error.localizedDescription)")
        }
        
        return ImageCacheStatistics(
            memoryCount: memoryCount,
            diskCount: diskCount,
            diskSize: diskSize
        )
    }
}

// MARK: - Cache Statistics
struct ImageCacheStatistics {
    let memoryCount: Int
    let diskCount: Int
    let diskSize: Int64
    
    var diskSizeMB: Double {
        return Double(diskSize) / 1024 / 1024
    }
    
    var description: String {
        return """
        📊 이미지 캐시 통계:
        • 메모리: 최대 \(memoryCount)개
        • 디스크: \(diskCount)개 파일
        • 디스크 크기: \(String(format: "%.1f", diskSizeMB))MB
        """
    }
}

// MARK: - Cached Image Loader (Observable)
final class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private var loadTask: Task<Void, Never>?
    
    func load(from url: URL) {
        // 기존 작업 취소
        loadTask?.cancel()
        
        // 이미 같은 URL의 이미지가 로드되어 있으면 스킵
        if image != nil && !isLoading {
            return
        }
        
        isLoading = true
        
        loadTask = Task {
            let loadedImage = await ImageCacheManager.shared.loadImage(from: url)
            
            await MainActor.run {
                if !Task.isCancelled {
                    self.image = loadedImage
                    self.isLoading = false
                }
            }
        }
    }
    
    func cancel() {
        loadTask?.cancel()
        loadTask = nil
        isLoading = false
    }
} 
