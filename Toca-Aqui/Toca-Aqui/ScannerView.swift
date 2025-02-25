//
//  ScannerView.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//

import SwiftUI
import VisionKit
import Vision

struct ScanDocumentView: UIViewControllerRepresentable {
    @Binding var recognisedText: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognisedText: $recognisedText, parent: self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) { }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var recognisedText: String
        var parent: ScanDocumentView

        init(recognisedText: Binding<String>, parent: ScanDocumentView) {
            self._recognisedText = recognisedText
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let extractedImages = extractImages(from: scan)
            let processedText = recognizeText(from: extractedImages)
            recognisedText = processedText
            controller.dismiss(animated: true)
        }

        private func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            var images = [CGImage]()
            for i in 0..<scan.pageCount {
                if let cgImage = scan.imageOfPage(at: i).cgImage {
                    images.append(cgImage)
                }
            }
            return images
        }

        private func recognizeText(from images: [CGImage]) -> String {
            var fullText = ""

            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
                for observation in observations {
                    if let topCandidate = observation.topCandidates(1).first {
                        fullText += topCandidate.string + "\n"
                    }
                }
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            for image in images {
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                try? handler.perform([request])
            }
            return fullText
        }
    }
}
