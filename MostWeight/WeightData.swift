import UIKit
import WebKit

final class WeightData: UIViewController {

    private enum JS {
        static let handlerName = "momentumHandler"
        static let acceptAction = "ACCEPT_TERMS"
    }

    private let url: URL
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.userContentController.add(self, name: JS.handlerName)

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = self
        wv.translatesAutoresizingMaskIntoConstraints = false

        wv.backgroundColor = .white
        wv.scrollView.backgroundColor = .white
        wv.isOpaque = true
        return wv
    }()

    var onAcceptTerms: (() -> Void)?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(
            forName: JS.handlerName
        )
        webView.navigationDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        assembleHierarchy()
        activateLayout()
        load()
    }

    private func configureAppearance() {
        view.backgroundColor = .black
        overrideUserInterfaceStyle = .dark
    }

    private func assembleHierarchy() {
        view.addSubview(webView)
    }

    private func activateLayout() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            webView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            webView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            webView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
        ])
    }

    private func load() {
        webView.load(URLRequest(url: url))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
    override var shouldAutorotate: Bool { true }
}

extension WeightData: WKNavigationDelegate {}

extension WeightData: WKScriptMessageHandler {

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == JS.handlerName else { return }

        if let action = actionString(from: message), action == JS.acceptAction {
            onAcceptTerms?()
        }
    }

    private func actionString(from message: WKScriptMessage) -> String? {
        if let dict = message.body as? [String: Any],
            let action = dict["action"] as? String
        {
            return action
        }
        return message.body as? String
    }
}
