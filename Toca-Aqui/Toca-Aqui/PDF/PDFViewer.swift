//
//  PDFViewer.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 06/03/25.
//

import SwiftUI
import PDFKit


struct PDFKitView: UIViewRepresentable {
    let pdfURL: URL

    func makeUIView(context: Context) -> UIView {
        // Container view with the desired background.
        let containerView = UIView()
        containerView.backgroundColor = UIColor.church_purple_color.withAlphaComponent(0.015)
        
        // Create PDFView with clear background.
        let pdfView = PDFView(frame: containerView.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        pdfView.backgroundColor = .clear
        
        if let document = PDFDocument(url: pdfURL) {
            pdfView.document = document
            print("PDF successfully loaded in PDFKit!")
        } else {
            print("Failed to load PDF.")
        }
        
        containerView.addSubview(pdfView)
        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

/*
 
 1) Uses UIViewRepresentable to embed a UIKit PDFView inside SwiftUI.
 2) Loads the PDF document from the provided pdfURL.
 3) Prints debugging messages when the PDF is loaded.

 

 It follows the same logic of the Scanner, we need an UIKit wrapper for use it inside SwiftUI
 
 
 */


struct PDFViewer: View {  //VIEW For displaying the file name of the PDF
    let pdfURL: URL

    var body: some View {
        ZStack {
            Color.church_purple_color
                .edgesIgnoringSafeArea(.all)
                .opacity(0.3)
                .zIndex(-1)
            
            PDFKitView(pdfURL: pdfURL)
            
        }
       
        
        
        .onAppear {
            print(" Opening PDF: \(pdfURL.path)")
            debugPrintPDFContents(url: pdfURL) // Debug PDF contents
        }
    }
}



// Function to debug PDF contents
func debugPrintPDFContents(url: URL) {
    guard let pdfDocument = PDFDocument(url: url) else {
        print(" PDF file could not be loaded.")
        return
    }

    for pageIndex in 0..<pdfDocument.pageCount {
        if let page = pdfDocument.page(at: pageIndex), let text = page.string {
            print(" Page \(pageIndex + 1): \(text)")
        } else {
            print(" Page \(pageIndex + 1) is empty or unreadable.")
        }
    }
}
