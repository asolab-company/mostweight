import SwiftUI

@MainActor
struct WeightView: UIViewControllerRepresentable {

    let url: URL
    var onAcceptTerms: (() -> Void)?

    init(url: URL, onAcceptTerms: (() -> Void)? = nil) {
        self.url = url
        self.onAcceptTerms = onAcceptTerms
    }

    typealias UIViewControllerType = WeightData

    func makeUIViewController(context: Context) -> UIViewControllerType {
        configure(WeightData(url: url))
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {

        uiViewController.onAcceptTerms = onAcceptTerms
    }

    private func configure(_ vc: UIViewControllerType) -> UIViewControllerType {
        vc.onAcceptTerms = onAcceptTerms
        return vc
    }

    final class Coordinator {}
    func makeCoordinator() -> Coordinator { Coordinator() }
}
