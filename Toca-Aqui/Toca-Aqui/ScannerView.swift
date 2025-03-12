//
//  ScannerView.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//

import SwiftUI
import VisionKit
import Vision

/*
 struct ScanDocumentView: UIViewControllerRepresentable { // UIViewControllerRepresentable wraps UIkit view controller, the camera
 @Binding var recognisedText: String  //Binding connects the state of this view with a state of an external view
 
 
 func makeCoordinator() -> Coordinator {
 /*
  The coordinator serves as an intermediary between the UIKit view controller and your SwiftUI view. It acts as a delegate, meaning it listens
  for events (such as user interactions or data updates) coming from the UIKit side. The coordinator serves as an intermediary between the UIKit
  view controller and your SwiftUI view. It acts as a delegate, meaning it listens for events (such as user interactions or data updates) coming
  from the UIKit side.
  */
 Coordinator(recognisedText: $recognisedText, parent: self)
 
 /*
  The method returns an instance of Coordinator. It’s a requirement when you need to manage delegate callbacks for a UIKit component wrapped in
  a SwiftUI view.
  
  recognisedText: $recognisedText --> Update the changed text
  
  parent: self --> Passing self (which refers to the current instance of your SwiftUI view) allows the coordinator to call back into the view if
  needed, accessing properties or methods.
  
  */
 }
 
 func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
 /*
  This method is required by the UIViewControllerRepresentable protocol.
  
  1) let scanner = VNDocumentCameraViewController(): Instantiates a new document camera view controller that provides an interface to scan documents.
  
  2) scanner.delegate = context.coordinator: Sets the coordinator (created earlier) as the delegate for the scanner.
  This means that the coordinator will handle events such as the completion of a scan.
  
  3) return scanner: Returns the configured view controller to be displayed by SwiftUI.
  */
 let scanner = VNDocumentCameraViewController()
 scanner.delegate = context.coordinator
 return scanner
 }
 
 func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) { } //Empty
 
 class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
 /*
  
  Defines a nested class named Coordinator that inherits from NSObject (a base class required for many UIKit delegate protocols) and conforms to
  VNDocumentCameraViewControllerDelegate. This delegate protocol allows the coordinator to respond to events from the document camera.
  
  */
 @Binding var recognisedText: String
 var parent: ScanDocumentView        //<-- These two are the ones declared in the function makeCoordinator()
 
 init(recognisedText: Binding<String>, parent: ScanDocumentView) {
 self._recognisedText = recognisedText
 self.parent = parent
 }   //Initializer
 
 func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
 
 //Calls a helper function to extract an array of images (as CGImage) from the scanned document.
 let extractedImages = extractImages(from: scan)
 
 //Processes the extracted images using text recognition, returning the recognized text as a single string.
 let processedText = recognizeText(from: extractedImages)
 
 //Updates the bound property so that any SwiftUI view observing this state reflects the new recognized text.
 recognisedText = processedText
 
 //Dismisses the document camera view controller, closing the scanning interface.
 controller.dismiss(animated: true)
 
 }
 
 //SAVING IMAGES WHILE SCANNING
 private func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
 var images = [CGImage]()
 for i in 0..<scan.pageCount {
 if let cgImage = scan.imageOfPage(at: i).cgImage {
 images.append(cgImage)
 }
 }
 return images
 }
 
 /*
  //This method takes an array of CGImage and processes them using the Vision framework’s text recognition capabilities
  private func recognizeText(from images: [CGImage]) -> String {
  
  var fullText = ""
  /*
   
   1) VNRecognizeTextRequest { request, error in ... }
   This initializes a text recognition request with a completion handler. When the request is performed on an image, this closure is called.
   
   2) guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
   Checks if the request’s results can be cast to an array of VNRecognizedTextObservation and that no error occurred. If not, it exits the closure.
   
   3) Looping through Observations: For each observation, it retrieves the most confident text candidate using topCandidates(1).
   
   4) if let topCandidate = observation.topCandidates(1).first { ... }
   Appends the recognized string (topCandidate.string) to fullText, adding a newline character for separation.
   
   */
  let request = VNRecognizeTextRequest { request, error in
  guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
  for observation in observations {
  if let topCandidate = observation.topCandidates(1).first {
  fullText += topCandidate.string + "\n"
  }
  }
  }
  
  
  //Sets the recognition level to .accurate for higher quality (though possibly slower) text recognition.
  request.recognitionLevel = .accurate
  
  // Enables language correction, which can improve the accuracy of the recognized text by correcting common mistakes.
  request.usesLanguageCorrection = true
  
  
  
  
  /*
   Processing Each Image:
   
   1) for image in images { ... } Loops through each CGImage in the array.
   
   2) let handler = VNImageRequestHandler(cgImage: image, options: [:]):
   Creates an image request handler for the current image. The empty options dictionary means no additional options are specified.
   
   3) try? handler.perform([request]):
   Attempts to perform the text recognition request on the image. The try? means that if an error occurs, it will be silently ignored.
   
   4) return fullText: After processing all images, returns the accumulated text from the document.
   
   */
  for image in images {
  let handler = VNImageRequestHandler(cgImage: image, options: [:])
  try? handler.perform([request])
  }
  return fullText
  
  }*/
 private func recognizeText(from images: [CGImage]) -> [(text: String, isTitle: Bool)] {
 var structuredText: [(String, Bool)] = [] // Stores text and its type (Title/Body)
 
 let request = VNRecognizeTextRequest { request, error in
 guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
 
 for observation in observations {
 if let topCandidate = observation.topCandidates(1).first {
 let isTitle = isLikelyTitle(topCandidate.string) // Detect if this is a title
 structuredText.append((topCandidate.string, isTitle))
 }
 }
 }
 
 request.recognitionLevel = .accurate
 request.usesLanguageCorrection = true
 
 for image in images {
 let handler = VNImageRequestHandler(cgImage: image, options: [:])
 try? handler.perform([request])
 }
 
 return structuredText
 }
 }
 
 }
 */






//PART 2


/*
 
 
 
 import SwiftUI
 import Vision
 
 struct ScanDocumentView: UIViewControllerRepresentable {
 @Binding var recognisedText: String
 @Binding var structuredText: [(text: String, isTitle: Bool)]
 
 func makeCoordinator() -> Coordinator {
 return Coordinator(recognisedText: $recognisedText, structuredText: $structuredText, parent: self)
 }
 
 func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
 let scanner = VNDocumentCameraViewController()
 scanner.delegate = context.coordinator
 return scanner
 }
 
 func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
 // No update required.
 }
 
 class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
 @Binding var recognisedText: String
 @Binding var structuredText: [(text: String, isTitle: Bool)]
 var parent: ScanDocumentView
 
 init(recognisedText: Binding<String>, structuredText: Binding<[(text: String, isTitle: Bool)]>, parent: ScanDocumentView) {
 self._recognisedText = recognisedText
 self._structuredText = structuredText
 self.parent = parent
 }
 
 func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
 let images = extractImages(from: scan)
 let structured = recognizeStructuredText(from: images)
 self.structuredText = structured
 // Also update the plain text by joining all text blocks.
 self.recognisedText = structured.map { $0.text }.joined(separator: "\n")
 controller.dismiss(animated: true)
 }
 
 // Extracts CGImages from the scanned document.
 private func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
 var images = [CGImage]()
 for i in 0..<scan.pageCount {
 if let cgImage = scan.imageOfPage(at: i).cgImage {
 images.append(cgImage)
 }
 }
 return images
 }
 
 // Recognizes text from each image, groups consecutive non-title observations into paragraphs,
 // and returns an array of (text, isTitle) tuples.
 private func recognizeStructuredText(from images: [CGImage]) -> [(text: String, isTitle: Bool)] {
 var globalResult: [(text: String, isTitle: Bool)] = []
 
 // Process each image individually.
 for image in images {
 var observationsArray: [(String, Bool)] = []
 
 let request = VNRecognizeTextRequest { request, error in
 guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
 for observation in observations {
 if let topCandidate = observation.topCandidates(1).first {
 let text = topCandidate.string
 let titleFlag = self.isLikelyTitle(text)
 observationsArray.append((text, titleFlag))
 }
 }
 }
 
 request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
 request.usesLanguageCorrection = true
 
 let handler = VNImageRequestHandler(cgImage: image, options: [:])
 try? handler.perform([request])
 
 // Group consecutive non-title observations into a paragraph.
 var groupedResult: [(text: String, isTitle: Bool)] = []
 var currentParagraph = ""
 
 for (text, isTitle) in observationsArray {
 if isTitle {
 // If there is accumulated non-title text, add it first.
 if !currentParagraph.isEmpty {
 groupedResult.append((currentParagraph, false))
 currentParagraph = ""
 }
 groupedResult.append((text, true))
 } else {
 if currentParagraph.isEmpty {
 currentParagraph = text
 } else {
 currentParagraph += " " + text
 }
 }
 }
 if !currentParagraph.isEmpty {
 groupedResult.append((currentParagraph, false))
 }
 
 globalResult.append(contentsOf: groupedResult)
 }
 return globalResult
 }
 
 // Helper function to decide if a text string is likely a title.
 private func isLikelyTitle(_ text: String) -> Bool {
 return text.count < 50 && text == text.uppercased()
 }
 
 // Generates a structured PDF from the text sections.
 
 }
 }
 
 */




import SwiftUI
import VisionKit
import Vision
import UIKit

struct ScanDocumentView: UIViewControllerRepresentable {
    @Binding var recognisedText: String
    @Binding var structuredText: [(text: String, isTitle: Bool)]
    
    // Called when the user taps the native Cancel button.
    var onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(recognisedText: $recognisedText,
                    structuredText: $structuredText,
                    parent: self)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        // Optionally add an instruction label if desired.
        
        
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No update needed.
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var recognisedText: String
        @Binding var structuredText: [(text: String, isTitle: Bool)]
        var parent: ScanDocumentView
        
        init(recognisedText: Binding<String>,
             structuredText: Binding<[(text: String, isTitle: Bool)]>,
             parent: ScanDocumentView) {
            self._recognisedText = recognisedText
            self._structuredText = structuredText
            self.parent = parent
        }
        
        // Called when the scanning is successfully completed.
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            let images = extractImages(from: scan)
            let structured = recognizeStructuredText(from: images)
            self.structuredText = structured
            self.recognisedText = structured.map { $0.text }.joined(separator: "\n")
            controller.dismiss(animated: true)
        }
        
        // This delegate method is called when the user taps the native Cancel button.
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.onCancel()
            controller.dismiss(animated: true)
        }
        
        // Helper: Extract images from the scan.
        private func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            var images = [CGImage]()
            for i in 0..<scan.pageCount {
                if let cgImage = scan.imageOfPage(at: i).cgImage {
                    images.append(cgImage)
                }
            }
            return images
        }
        
        // Helper: Recognize structured text from the images.
        private func recognizeStructuredText(from images: [CGImage]) -> [(text: String, isTitle: Bool)] {
            var globalResult: [(text: String, isTitle: Bool)] = []
            for image in images {
                var observationsArray: [(String, Bool)] = []
                let request = VNRecognizeTextRequest { request, error in
                    guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
                    for observation in observations {
                        if let topCandidate = observation.topCandidates(1).first {
                            let text = topCandidate.string
                            let titleFlag = self.isLikelyTitle(text)
                            observationsArray.append((text, titleFlag))
                        }
                    }
                }
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                try? handler.perform([request])
                
                var groupedResult: [(text: String, isTitle: Bool)] = []
                var currentParagraph = ""
                for (text, isTitle) in observationsArray {
                    if isTitle {
                        if !currentParagraph.isEmpty {
                            groupedResult.append((currentParagraph, false))
                            currentParagraph = ""
                        }
                        groupedResult.append((text, true))
                    } else {
                        if currentParagraph.isEmpty {
                            currentParagraph = text
                        } else {
                            currentParagraph += " " + text
                        }
                    }
                }
                if !currentParagraph.isEmpty {
                    groupedResult.append((currentParagraph, false))
                }
                globalResult.append(contentsOf: groupedResult)
            }
            return globalResult
        }
        
        private func isLikelyTitle(_ text: String) -> Bool {
            return text.count < 50 && text == text.uppercased()
        }
    }
}


