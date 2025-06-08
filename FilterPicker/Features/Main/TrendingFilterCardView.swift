import SwiftUI

struct TrendingFilterCardView: View {
    let filter: HotTrendFilter
    let isCenter: Bool
    let scale: CGFloat
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let isDragging: Bool
    let onLikeTapped: () -> Void

    var body: some View {
        Group {
            if isDragging {
                // 드래그 중일 때는 NavigationLink 비활성화
                cardContent
            } else {
                // 드래그 중이 아닐 때만 NavigationLink 활성화
                NavigationLink(destination: FilterDetailView(filterId: filter.filterId)) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .scaleEffect(scale)
        .shadow(
            radius: isCenter ? 8 : 2,
            x: 0,
            y: isCenter ? 4 : 2
        )
        .animation(.easeInOut(duration: 0.4), value: isCenter)
        .animation(.easeInOut(duration: 0.4), value: scale)
    }
    
    private var cardContent: some View {
            ZStack(alignment: .topLeading) {
                if let url = URL(string: filter.filteredImageURL) {
                    URLImageView(url: url, showOverlay: false, contentMode: .fill)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                        .cornerRadius(20)
                        .overlay(
                            Color.black
                                .opacity(isCenter ? 0 : 0.6)
                                .animation(.easeInOut(duration: 0.4), value: isCenter)
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
                    .opacity(isCenter ? 1.0 : 0.7)
                    .animation(.easeInOut(duration: 0.4), value: isCenter)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            onLikeTapped()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: filter.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(filter.isLiked ? .red : .white)
                                Text("\(filter.likeCount)")
                                    .fontStyle(.caption1)
                                    .foregroundColor(.gray30)
                            }
                            .padding(8)
                            .background(
                                Color.black
                                    .opacity(isCenter ? 0.4 : 0.2)
                                    .animation(.easeInOut(duration: 0.4), value: isCenter)
                            )
                            .cornerRadius(8)
                            .opacity(isCenter ? 1.0 : 0.8)
                            .animation(.easeInOut(duration: 0.4), value: isCenter)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding([.bottom, .trailing], 12)
                    }
                }
            }
            .frame(width: cardWidth, height: cardHeight)
    }
} 
