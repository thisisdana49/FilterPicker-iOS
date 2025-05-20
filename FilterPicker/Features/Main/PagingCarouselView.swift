import SwiftUI

struct PagingCarouselView<Data, Content>: UIViewRepresentable where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View {
    let data: Data
    @Binding var currentIndex: Int
    let cardWidth: CGFloat
    let spacing: CGFloat
    let content: (Data.Element, Bool) -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = false
        scrollView.decelerationRate = .fast
        scrollView.delegate = context.coordinator
        scrollView.clipsToBounds = false

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        context.coordinator.stackView = stackView
        context.coordinator.scrollView = scrollView
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard let stackView = context.coordinator.stackView else { return }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let centerIndex = currentIndex
        for (idx, item) in data.enumerated() {
            let isCenter = idx == centerIndex
            let host = UIHostingController(rootView: content(item, isCenter))
            host.view.translatesAutoresizingMaskIntoConstraints = false
            host.view.backgroundColor = .clear
            host.view.widthAnchor.constraint(equalToConstant: cardWidth).isActive = true
            stackView.addArrangedSubview(host.view)
        }

        // 좌우 여백 추가
        let sideInset = (scrollView.bounds.width - cardWidth) / 2
        scrollView.contentInset = UIEdgeInsets(top: 0, left: max(sideInset, 0), bottom: 0, right: max(sideInset, 0))

        // 중앙 카드로 스크롤
        let targetX = CGFloat(centerIndex) * (cardWidth + spacing) - scrollView.contentInset.left
        if abs(scrollView.contentOffset.x - targetX) > 1 {
            scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        }
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: PagingCarouselView
        weak var stackView: UIStackView?
        weak var scrollView: UIScrollView?

        init(_ parent: PagingCarouselView) {
            self.parent = parent
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            updateCurrentIndex(scrollView)
        }
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate { updateCurrentIndex(scrollView) }
        }
        private func updateCurrentIndex(_ scrollView: UIScrollView) {
            let cardWidthWithSpacing = parent.cardWidth + parent.spacing
            let offset = scrollView.contentOffset.x + scrollView.contentInset.left
            let index = Int(round(offset / cardWidthWithSpacing))
            if index != parent.currentIndex && index >= 0 && index < parent.data.count {
                DispatchQueue.main.async {
                    self.parent.currentIndex = index
                }
            }
            // 스냅
            let targetX = CGFloat(index) * cardWidthWithSpacing - scrollView.contentInset.left
            scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        }
    }
} 