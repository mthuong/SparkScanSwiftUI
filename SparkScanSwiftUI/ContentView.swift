import SwiftUI
import ScanditBarcodeCapture

struct ContentView: View {
    @State var barcodes: [Barcode] = []
    private let sparkScanViewController = SparkScanViewController()

    var body: some View {
        VStack {
            Button("Clear list") {
                barcodes = []
            }.padding(.top)
            List(barcodes, id: \.self) { barcode in
                VStack(alignment: .leading) {
                    Text(barcode.data ?? "")
                    Text(barcode.symbology.description).font(.footnote)
                }
            }
        }
        .withSparkScan(sparkScanViewController)
        .onAppear {
            sparkScanViewController.onScan = { barcode in
                barcodes.append(barcode)
            }
        }
    }
}

#Preview {
    ContentView()
}
