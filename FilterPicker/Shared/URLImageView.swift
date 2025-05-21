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
            } else {
                ProgressView()
            }
        }
        .onAppear { loader.load(from: url) }
        .onDisappear { loader.cancel() }
    }
} 
