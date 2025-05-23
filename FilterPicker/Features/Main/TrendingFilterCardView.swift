import SwiftUI

struct TrendingFilterCardView: View {
    let filter: HotTrendFilter
    let isCenter: Bool
    let scale: CGFloat
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let firstFile = filter.files.first,
               let url = URL(string: AppConfig.baseURL + "/v1/" + firstFile) {
                URLImageView(url: url, showOverlay: false)
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()
                    .cornerRadius(20)
                    .overlay(
                        Color.black.opacity(isCenter ? 0 : 0.6)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray30)
                    .frame(width: cardWidth, height: cardHeight)
                    .cornerRadius(20)
            }
            Text(filter.title)
                .fontStyle(.mulgyeolCaption1)
                .foregroundColor(.gray30)
                .padding([.top, .leading], 12)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                        Text("\(filter.likeCount)")
                            .fontStyle(.caption1)
                            .foregroundColor(.gray30)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                    .padding([.bottom, .trailing], 12)
                }
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .scaleEffect(scale)
        .shadow(radius: isCenter ? 8 : 2)
        .animation(.easeInOut(duration: 0.3), value: isCenter)
    }
} 
