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
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No update needed.
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var recognisedText: String
        @Binding var structuredText: [(text: String, isTitle: Bool)]
        var parent: ScanDocumentView
        
        // Mapping dictionaries for known texts
        
        let lisTextMapping: [String: String] = [
            """
            PREPARIAMO LE VIE
            DEL SIGNORE CHE VIENE
            Chi tra di noi ascolterà Giovanni Battista e farà vere e pro-
            prie scelte di conversione? Ricordandoci che la conver-
            sione non è farci santi con la nostra bravura, bensì orienta-
            re la nostra vita verso la misericordia divina che sta per ma-
            nifestarsi, volgerci verso l'Amore che viene a salvarci! Si
            tratta di preparare - insieme - la via del Signore, di togliere
            tutti gli ostacoli, in noi e tra noi, che impediscono alla tene-
            rezza divina di raggiungerci (/ Lettura e Vangelo). Allora po-
            trà manifestarsi il "battesimo di fuoco"; il fuoco dell'Amore
            che consuma il non-amore tra noi, e fa ardere i nostri cuori.
            L'Avvento ci chiama alla conversione del cuore, così da
            affrettare la venuta del giorno del Signore. Dobbiamo prepa-
            rarci insieme, perché verranno nuovi cieli e una terra nuova
            nei quali la giustizia - e solo essa - abiterà (II Lettura). Dob-
            biamo prepararvi il mondo intorno a noi: Dio vuole che nes-
            suno si perda, ma questo dipende anche dalla nostra testi-
            monianza! La tua vita farà intravedere agli altri la bellezza
            della speranza? Coraggio! È la tua missione!
            fr. Antoine-Emmanuel, Frat. Monast. di Gerusalemme, Firenze
            """:
            """
            **PREPARIAMO LE VIE **
            **DEL SIGNORE CHE VIENE**

            Chi tra noi ascolterà Giovanni Battista?
            Chi cambierà vita per accogliere il Signore?
            Convertirsi non significa diventare santi da soli con le nostre forze.
            Significa aprire il cuore all’amore di Dio, che sta per venire.
            Dobbiamo prepararci insieme!
            Togliere gli ostacoli che ci separano da Dio e dagli altri.
            Così la tenerezza di Dio potrà raggiungerci.
            Quando il Signore verrà, ci sarà un battesimo di fuoco:
            il fuoco dell’Amore che brucia tutto ciò che è male e accende i nostri cuori.
            L’Avvento ci invita a cambiare cuore.
            Dobbiamo prepararci, perché Dio promette un mondo nuovo,
            fatto di pace e giustizia.
            Ma non basta aspettare: Dobbiamo prepararci insieme!
            Dio vuole salvare tutti, ma la nostra testimonianza è importante.
            La tua vita mostrerà agli altri la bellezza della speranza?
            Coraggio! Questa è la tua missione!
            """
        ]
        
        let firstColumn: [String: String] = [
            """
            ANTIFONA D'INGRESSO (Cfr. Is 30,19.30) in piedi
            Popolo di Sion, il Signore verrà a salvare le
            genti, e farà udire la sua voce maestosa nel-
            la letizia del vostro cuore.
            Celebrante - Nel nome del Padre e del Figlio e
            dello Spirito Santo. Assemblea Amen.
            C-II Dio della speranza, che ci riempie di ogni
            gioia e pace nella fede per la potenza dello Spi-
            rito Santo, sia con tutti voi.
            ATTO PENITENZIALE
            A-E con il tuo spirito.
            (si può cambiare)
            C-Fratelli e sorelle, è attraverso la voce di Gio-
            vanni Battista che oggi il Signore ci esorta ad
            aprire il nostro cuore alla sua parola, perché la
            grazia del perdono ci liberi da ogni corruzione
            di peccato.
            Breve pausa al silenzio.
            -Signore, che sei venuto nel mondo per salvar-
            ci, Kýrie, eléison.
            A-Kýrie, eléison. -Cristo, che vieni a visitarci con la grazia del tuo
            Spirito, Christe, eléison. A-Christe, eléison.
            -Signore, che verrai un giorno a giudicare le no-
            stre opere, Kýrie, eléison. A- Kýrie, eléison.
            C-Dio onnipotente abbia misericordia di noi,
            perdoni i nostri peccati e ci conduca alla vita
            eterna.
            A-Amen.
            Non si dice il Gloria.
            """:
            """
            **ANTIFONA D’INGRESSO**

            Guida: Popolo di Sion, il Signore viene per salvare tutti.
            Dio parlerà con voce potente e porterà gioia nei vostri cuori!
            
            Celebrante: Nel nome del Padre, del Figlio e dello Spirito Santo.

            Tutti: Amen!

            Celebrante: Dio della speranza ci dona gioia e pace.
            Che il suo Spirito Santo sia con voi.

            Tutti: E con il tuo spirito.


            **ATTO PENITENZIALE**

            Celebrante: Fratelli e sorelle, oggi il Signore ci parla attraverso Giovanni Battista.
            Ci invita ad aprire il cuore alla sua parola. Dio vuole perdonarci e liberarci dal peccato.
            Facciamo un momento di silenzio.

            

            Signore, tu sei venuto nel mondo per salvarci.
            Kýrie, eléison.
            
            Tutti: Kýrie, eléison.
            Cristo, tu vieni a visitarci con il tuo Spirito.
            Christe, eléison.
                
            Tutti: Christe, eléison.
            Signore, un giorno verrai per giudicare le nostre azioni.
            Kýrie, eléison.
            
            Tutti: Kýrie, eléison.

            Celebrante: Dio onnipotente ci perdoni, ci liberi dal peccato e ci guidi alla vita eterna.

            Tutti: Amen!

            
            """
        ]
        
        let secondColumn: [String: String] = [
            """
            ORAZIONE COLLETTA
            C-Dio grande e misericordioso, fa' che il no-
            stro impegno nel mondo non ci ostacoli nel
            cammino verso il tuo Figlio, ma la sapienza
            che viene dal cielo ci guidi alla comunione
            con il Cristo, nostro Salvatore. Egli è Dio, e vi-
            ve e regna...
            A-Amen.
            Oppure:
            C-O Dio, Padre di ogni consolazione, che
            all'umanità pellegrina nel tempo hai promesso
            nuovi cieli è terra nuova, parla oggi al cuore
            del tuo popolo, perché, in purezza di fede e
            santità di vita, possa camminare verso il gior
            no in oui ti manifesteral plenamente e ogni uo
            mo vedrà la tua salvezza. Per il nostro Signo-
            re Gesù Cristo...
            A Amen. 15
            """:
            """
            **ORAZIONE COLLETTA**

            Celebrante:
            Dio grande e buono,
            aiutaci a vivere bene nel mondo,
            senza dimenticare di seguire Gesù.

            Fa’ che la tua sapienza ci guidi
            e ci avvicini sempre di più a Cristo, nostro Salvatore,
            che vive e regna per sempre.

            Tutti: Amen!

            Tutti: Amen!
            """
        ]
        
        // Combined mapping dictionaries
        var mappingDictionaries: [String: String] {
            var combined = lisTextMapping
            for (key, value) in firstColumn {
                combined[key] = value
            }
            for (key, value) in secondColumn {
                combined[key] = value
            }
            return combined
        }
        
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
        
        // Called when the user taps the native Cancel button.
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.onCancel()
            controller.dismiss(animated: true)
        }
        
        // Extract images from the scan.
        private func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            var images = [CGImage]()
            for i in 0..<scan.pageCount {
                if let cgImage = scan.imageOfPage(at: i).cgImage {
                    images.append(cgImage)
                }
            }
            return images
        }
        
        // Recognize text from the scanned images and try to match it with known texts.
        private func recognizeStructuredText(from images: [CGImage]) -> [(text: String, isTitle: Bool)] {
            var globalResult: [(text: String, isTitle: Bool)] = []
            
            // Process each image.
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
            
            // Combine all recognized text into one block.
            let fullScannedText = globalResult.map { $0.text }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Normalize the scanned text.
            let normalizedScannedText = normalizeText(fullScannedText)
            print("Normalized Scanned Text:\n\(normalizedScannedText)")
            
            // Check each mapping dictionary using fuzzy matching.
            for (original, lisVersion) in mappingDictionaries {
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
            
            // If no match is found, return the original structured result.
            return globalResult
        }
        
        // Parse the known LIS-friendly text into structured blocks.
        private func parseStructuredLIS(_ text: String) -> [(text: String, isTitle: Bool)] {
            var blocks: [(String, Bool)] = []
            let lines = text.components(separatedBy: "\n")
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                if trimmed.hasPrefix("**") && trimmed.hasSuffix("**") {
                    let title = trimmed.replacingOccurrences(of: "**", with: "").trimmingCharacters(in: .whitespaces)
                    blocks.append((title, true))
                } else {
                    blocks.append((trimmed, false))
                }
            }
            return blocks
        }
        
        // Normalize text by removing hyphenated line breaks and extra spaces.
        private func normalizeText(_ text: String) -> String {
            let withoutHyphenLineBreaks = text.replacingOccurrences(of: "-\n", with: "")
            let withoutNewlines = withoutHyphenLineBreaks.replacingOccurrences(of: "\n", with: " ")
            let trimmed = withoutNewlines.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.lowercased()
        }
        
        // A simple heuristic: if text is short and entirely uppercase, treat it as a title.
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
