//
//  ScannerView.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//


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
        
        // Dictionary to map original text to LIS-friendly versions
        let lisTextMapping: [String: String] = [
            """
            RITI DI ACCOGLIENZA
            ANTIFONA D'INGRESSO
            Cantate al Signore un canto nuovo, can-
            tate al Signore, uomini di tutta la terra.
            Maestà conore sono davanti a lui, forza
            e splendore nel suo santuario.
            Cel. Nel nome del Padre e del Figlio e del-
            lo Spirito Santo.
            Ass. Amen.
            Cel. Il Signore, che guida i nostri cuori
            all'amore e alla pazienza di Cristo, sia con
            tutti voi.
            Ass. E con il tuo spirito.
            ATTO PENITENZIALE
            Cel. Fratelli e sorelle, all'inizio di questa
            celebrazione eucaristica, invochiamo la
            misericordia di Dio, fonte di riconciliazio-
            ne e di comunione.
            Segue una breve pausa di silenzio.
            Cel. Pietà di noi, Signore.
            Ass. Contro di te abbiamo peccato.
            Cel. Mostraci, Signore, la tua misericordia.
            Ass. E donaci la tua salvezza.
            Cel. Dio onnipotente abbia misericordia di
            noi, perdoni i nostri peccati e ci conduca
            alla vita eterna.
            Cel. Kýrie, eléison.
            Cel. Christe, eléison.
            Cel. Kýrie, eléison.
            Ass. Amen.
            Ass. Kýrie, eléison.
            Ass. Christe, eléison.
            Ass. Kýrie, eléison.
            """:
            """
            **RITI DI ACCOGLIENZA**

            **CANTO DI INGRESSO**  
            Cantiamo un canto nuovo per Dio.  
            Tutte le persone della terra lodino Dio.  
            Dio è grande e potente.  
            Dio è pieno di luce e bellezza.  

             
            Sacerdote: Nel nome del Padre, del Figlio e dello Spirito Santo.  
            Assemblea: Amen.  

            Sacerdote: Il Signore ci aiuta ad amare e ad avere pazienza, sia con tutti voi.  
            Assemblea: E con il tuo spirito.  


            **ATTO PENITENZIALE**  
            Sacerdote: Fratelli e sorelle, prima di iniziare la preghiera, chiediamo perdono a Dio per i nostri errori. Dio ci ama e ci perdona.  

            (Silenzio per riflettere)  

            Sacerdote: Signore, abbi pietà di noi.  
            Assemblea: Abbiamo sbagliato contro di te.  

            Sacerdote: Signore, mostraci il tuo amore.  
            Assemblea: Donaci il tuo perdono.  

            Sacerdote: Dio è buono. Lui ci perdona e ci dà la vita eterna.  

            Sacerdote: Signore, abbi pietà.  
            Assemblea: Signore, abbi pietà.  

            Sacerdote: Cristo, abbi pietà.  
            Assemblea: Cristo, abbi pietà.  

            Sacerdote: Signore, abbi pietà.  
            Assemblea: Signore, abbi pietà.
            """
        ]
        
        
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
        
        //  Extract images from the scan.
        private func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            var images = [CGImage]()
            for i in 0..<scan.pageCount {
                if let cgImage = scan.imageOfPage(at: i).cgImage {
                    images.append(cgImage)
                }
            }
            return images
        }
        
        
        private func recognizeStructuredText(from images: [CGImage]) -> [(text: String, isTitle: Bool)] {
            var globalResult: [(text: String, isTitle: Bool)] = []
            
            // Process each image one by one.
            for image in images {
                var observationsArray: [(String, Bool)] = []
                let semaphore = DispatchSemaphore(value: 0)
                
                let request = VNRecognizeTextRequest { request, error in
                    defer { semaphore.signal() }
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
                semaphore.wait()  // Wait until text recognition completes
                
                // Group consecutive non-title observations into paragraphs.
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
            
            // Combine all recognized text into one single block.
            let fullScannedText = globalResult.map { $0.text }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Normalize the scanned text.
            let normalizedScannedText = normalizeText(fullScannedText)
            print("Normalized Scanned Text:\n\(normalizedScannedText)")
            
            // Check the mapping dictionary using fuzzy word matching.
            for (original, lisVersion) in lisTextMapping {
                let normalizedOriginal = normalizeText(original)
                print("Normalized Expected Text:\n\(normalizedOriginal)")
                
                let expectedWords = normalizedOriginal.split(separator: " ")
                let scannedWords = normalizedScannedText.split(separator: " ")
                let commonWords = expectedWords.filter { scannedWords.contains($0) }
                let ratio = Double(commonWords.count) / Double(expectedWords.count)
                print("Fuzzy match ratio: \(ratio)")
                
                if ratio >= 0.7 {  // if at least 70% of the expected words are found
                    print("Fuzzy match found (ratio \(ratio)). Returning structured LIS-friendly version.")
                    return parseStructuredLIS(lisVersion)
                }
            }
            
            // If no fuzzy match is found, return the structured result as usual.
            return globalResult
        }
        
        private func parseStructuredLIS(_ text: String) -> [(text: String, isTitle: Bool)] {
            var blocks: [(String, Bool)] = []
            // Split the text into lines.
            let lines = text.components(separatedBy: "\n")
            
            // Process each line.
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                
                // If the line starts and ends with "**", consider it a title.
                if trimmed.hasPrefix("**") && trimmed.hasSuffix("**") {
                    let title = trimmed.replacingOccurrences(of: "**", with: "").trimmingCharacters(in: .whitespaces)
                    blocks.append((title, true))
                } else {
                    // Otherwise, treat it as a body text block.
                    blocks.append((trimmed, false))
                }
            }
            return blocks
        }
        
        private func normalizeText(_ text: String) -> String {
            // Remove hyphenated line breaks.
            let withoutHyphenLineBreaks = text.replacingOccurrences(of: "-\n", with: "")
            // Replace newlines with a space.
            let withoutNewlines = withoutHyphenLineBreaks.replacingOccurrences(of: "\n", with: " ")
            // Reduce multiple spaces and trim.
            let trimmed = withoutNewlines.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.lowercased()
        }
    
        
        private func isLikelyTitle(_ text: String) -> Bool {
            return text.count < 50 && text == text.uppercased()
        }
    }
}




//PREVIOUS CODE WITH EXPLANATION:


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
