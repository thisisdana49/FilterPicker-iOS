import SwiftUI

struct URLImageView: View {
    @StateObject private var loader = URLImageLoader()
    let url: URL
    let showOverlay: Bool

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        showOverlay ?
                        Image("GradientBackground")
                            .resizable()
                            .scaledToFit()
                        : nil
                    )
            } else if loader.image == nil {
                ZStack {
                    Color.blackTurquoise
                    Image(systemName: "photo.badge.exclamationmark.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray60)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear { loader.load(from: url) }
        .onDisappear { loader.cancel() }
    }
} 
