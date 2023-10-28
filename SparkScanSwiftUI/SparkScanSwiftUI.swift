import SwiftUI
import UIKit

extension View {
    func withSparkScan(_ viewController: UIViewController) -> some View {
        modifier(SparkScanModifier(with: viewController))
    }
}

private struct SparkScanModifier: ViewModifier {
    private let sparkScanViewController: UIViewController

    init(with viewController: UIViewController) {
        self.sparkScanViewController = viewController
    }

    func body(content: Content) -> some View {
        SparkScanViewRepresentable(sparkScanViewController: sparkScanViewController) {
            content
        }.edgesIgnoringSafeArea(.all)
    }
}

private struct SparkScanViewRepresentable<Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = SparkScanHostingViewController<Content>

    let sparkScanViewController: UIViewController
    @ViewBuilder let content: Content

    func makeUIViewController(context: Context) -> UIViewControllerType {
        return SparkScanHostingViewController(content: content,
                                              sparkScanViewController: sparkScanViewController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

private class SparkScanHostingViewController<Content: View>: UIViewController {
    private let content: UIHostingController<Content>
    private let sparkScanViewController: UIViewController

    init(content: Content, sparkScanViewController: UIViewController) {
        self.content = UIHostingController(rootView: content)
        self.sparkScanViewController = sparkScanViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func loadView() {
        view = PassthroughView(frame: UIScreen.main.bounds,
                               content: content,
                               sparkScanViewController: sparkScanViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupContent()
        setupSparkScanViewController()
    }

    private func setupContent() {
        addChild(content)
        view.addSubview(content.view)
        content.didMove(toParent: self)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.view.topAnchor.constraint(equalTo: view.topAnchor),
            content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSparkScanViewController() {
        addChild(sparkScanViewController)
        view.addSubview(sparkScanViewController.view)
        sparkScanViewController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            sparkScanViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sparkScanViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sparkScanViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            sparkScanViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

private class PassthroughView<Content: View>: UIView {
    private let content: UIHostingController<Content>
    private let sparkScanViewController: UIViewController

    init(frame: CGRect, content: UIHostingController<Content>, sparkScanViewController: UIViewController) {
        self.content = content
        self.sparkScanViewController = sparkScanViewController
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != sparkScanViewController.view else {
            return content.view.hitTest(point, with: event)
        }
        return view
    }
}
