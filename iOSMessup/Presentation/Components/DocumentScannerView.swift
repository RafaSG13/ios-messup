//
//  DocumentScannerView.swift
//  iOSMessup
//

import SwiftUI
import VisionKit

// MARK: - DocumentScannerView

/// The system document camera. Reports the first scanned page; `isSupported` is false on the simulator.
struct DocumentScannerView: UIViewControllerRepresentable {
    let onScan: (CGImage) -> Void
    let onCancel: () -> Void

    static var isSupported: Bool {
        VNDocumentCameraViewController.isSupported
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: VNDocumentCameraViewController, context: Context) {
        context.coordinator.onScan = onScan
        context.coordinator.onCancel = onCancel
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var onScan: (CGImage) -> Void
        var onCancel: () -> Void

        init(onScan: @escaping (CGImage) -> Void, onCancel: @escaping () -> Void) {
            self.onScan = onScan
            self.onCancel = onCancel
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0, let image = scan.imageOfPage(at: 0).cgImage else {
                onCancel()
                return
            }
            onScan(image)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            onCancel()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: any Error) {
            onCancel()
        }
    }
}

// MARK: - Preview

#Preview {
    Text("The document camera is not available in previews.")
        .multilineTextAlignment(.center)
        .padding()
}
