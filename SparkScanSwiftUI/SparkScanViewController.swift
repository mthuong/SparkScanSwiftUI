import UIKit
import ScanditCaptureCore
import ScanditBarcodeCapture

final class SparkScanViewController: UIViewController {
    private var context: DataCaptureContext
    private var sparkScan: SparkScan!
    private var sparkScanView: SparkScanView!
    var onScan: ((Barcode) -> Void)?

    // MARK: - Lifecycle
    init() {
        self.context = DataCaptureContext(licenseKey: "")
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSparkScan()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sparkScanView.prepareScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sparkScanView.stopScanning()
    }

    // MARK: - Setup
    private func setupSparkScan() {
        let settings = SparkScanSettings()
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)
        sparkScan = SparkScan(settings: settings)
        sparkScan.addListener(self)

        let viewSettings = SparkScanViewSettings()
        sparkScanView = SparkScanView(parentView: view, context: context, sparkScan: sparkScan, settings: viewSettings)
    }
}

// MARK: - SparkScanListener
extension SparkScanViewController: SparkScanListener {
    func sparkScan(_ sparkScan: SparkScan,
                   didScanIn session: SparkScanSession,
                   frameData: FrameData?) {
        // Gather the recognized barcode
        let barcode = session.newlyRecognizedBarcodes.first
        // This method is invoked from a recognition internal thread.
        // Dispatch to the main thread to update the internal barcode list.
        DispatchQueue.main.async { [weak self] in
            // Emit sound and vibration feedback
            self?.sparkScanView.emitFeedback(SparkScanViewSuccessFeedback())
            // Handle the barcode
            guard let barcode else { return }
            self?.onScan?(barcode)
        }
    }
}

