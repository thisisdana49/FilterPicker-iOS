//
//  CachedImageView.swift
//  FilterPicker
//
//  Created by 조다은 on 5/24/25.
//

import SwiftUI

// MARK: - Cached Image View
struct CachedImageView: View {
    @StateObject private var loader = CachedImageLoader()
    
    let url: URL
    let showOverlay: Bool
    let contentMode: ContentMode
    
    init(url: URL, showOverlay: Bool = false, contentMode: ContentMode = .fill) {
        self.url = url
        self.showOverlay = showOverlay
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode.aspectRatio)
                    .overlay(
                        showOverlay ?
                        Image("GradientBackground")
                            .resizable()
                            .scaledToFit()
                        : nil
                    )
            } else if loader.isLoading {
                ZStack {
                    Color.blackTurquoise
                    
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        
                        Text("이미지 로딩 중...")
                            .font(.caption2)
                            .foregroundColor(.gray60)
                    }
                }
            } else {
                // 로딩 실패 또는 초기 상태
                ZStack {
                    Color.blackTurquoise
                    
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.exclamationmark.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.gray60)
                        
                        Text("이미지 없음")
                            .font(.caption2)
                            .foregroundColor(.gray60)
                    }
                }
            }
        }
        .onAppear {
            loader.load(from: url)
        }
        .onDisappear {
            // View가 사라질 때 로딩 취소 (메모리 절약)
            loader.cancel()
        }
    }
}

// MARK: - Content Mode Enum
extension CachedImageView {
    enum ContentMode {
        case fit
        case fill
        
        var aspectRatio: SwiftUI.ContentMode {
            switch self {
            case .fit: return .fit
            case .fill: return .fill
            }
        }
    }
}

// MARK: - Backwards Compatibility
typealias URLImageView = CachedImageView

// MARK: - Preview
#if DEBUG
struct CachedImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 정상 이미지
            if let url = URL(string: "https://example.com/image.jpg") {
                CachedImageView(url: url)
                    .frame(width: 200, height: 150)
                    .cornerRadius(12)
            }
            
            // 오버레이 포함
            if let url = URL(string: "https://example.com/image2.jpg") {
                CachedImageView(url: url, showOverlay: true)
                    .frame(width: 200, height: 150)
                    .cornerRadius(12)
            }
            
            // Fit 모드
            if let url = URL(string: "https://example.com/image3.jpg") {
                CachedImageView(url: url, contentMode: .fit)
                    .frame(width: 200, height: 150)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.black)
    }
}
#endif

// MARK: - Cache Management View (Debug/Settings)
struct ImageCacheManagementView: View {
    @State private var statistics: ImageCacheStatistics?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("이미지 캐시 관리")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if let stats = statistics {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📊 캐시 통계")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("• 메모리: 최대 \(stats.memoryCount)개")
                        .foregroundColor(.gray)
                    
                    Text("• 디스크: \(stats.diskCount)개 파일")
                        .foregroundColor(.gray)
                    
                    Text("• 디스크 크기: \(String(format: "%.1f", stats.diskSizeMB))MB")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }
            
            VStack(spacing: 12) {
                Button("📊 통계 새로고침") {
                    refreshStatistics()
                }
                .buttonStyle(CacheManagementButtonStyle())
                
                Button("🧹 메모리 캐시 정리") {
                    ImageCacheManager.shared.clearMemoryCache()
                    refreshStatistics()
                }
                .buttonStyle(CacheManagementButtonStyle())
                
                Button("💾 디스크 캐시 정리") {
                    isLoading = true
                    Task {
                        await ImageCacheManager.shared.clearDiskCache()
                        await MainActor.run {
                            refreshStatistics()
                            isLoading = false
                        }
                    }
                }
                .buttonStyle(CacheManagementButtonStyle())
                .disabled(isLoading)
                
                Button("🗑️ 모든 캐시 정리") {
                    isLoading = true
                    Task {
                        await ImageCacheManager.shared.clearAllCaches()
                        await MainActor.run {
                            refreshStatistics()
                            isLoading = false
                        }
                    }
                }
                .buttonStyle(CacheManagementButtonStyle(destructive: true))
                .disabled(isLoading)
            }
            
            if isLoading {
                ProgressView("처리 중...")
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black)
        .onAppear {
            refreshStatistics()
        }
    }
    
    private func refreshStatistics() {
        statistics = ImageCacheManager.shared.getCacheStatistics()
    }
}

// MARK: - Cache Management Button Style
struct CacheManagementButtonStyle: ButtonStyle {
    let destructive: Bool
    
    init(destructive: Bool = false) {
        self.destructive = destructive
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundColor(destructive ? .white : .black)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(destructive ? Color.red : Color.white)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview for Cache Management
#if DEBUG
struct ImageCacheManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCacheManagementView()
    }
}
#endif 
