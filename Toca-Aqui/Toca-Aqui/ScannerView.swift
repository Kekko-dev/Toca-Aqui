//
//  ScannerView.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//


import SwiftUI
import AVFoundation
import Vision

// 2. Implementing the view responsible for scanning the data
struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedText: String
    
    let captureSession = AVCaptureSession()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return viewController }
        
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 3. Implementing the Coordinator class
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: ScannerView
        
        init(_ parent: ScannerView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            self.detectText(in: pixelBuffer)
        }
        
        func detectText(in pixelBuffer: CVPixelBuffer) {
            let request = VNRecognizeTextRequest { (request, error) in
                guard let results = request.results as? [VNRecognizedTextObservation],
                      let recognizedText = results.first?.topCandidates(1).first?.string else { return }
                
                self.parent.recognizedText = recognizedText
                
                // Optionally, stop scanning after first detection
                // self.parent.captureSession.stopRunning()
            }
            
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Text recognition failed: \(error)")
            }
        }
    }
    
}

