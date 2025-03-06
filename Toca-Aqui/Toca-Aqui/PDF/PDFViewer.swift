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

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView() // Creates a PDFView (UIKit component for displaying PDFs).
        pdfView.autoScales = true // pdfView.autoScales = true → Automatically zooms the PDF to fit the screen.
        
        if let document = PDFDocument(url: pdfURL) { // Loads the PDF file from the provided pdfURL.
            pdfView.document = document
            print(" PDF successfully loaded in PDFKit !")
        } else {
            print(" Failed to load PDF.")
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
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
        VStack {
            Text("Opening: \(pdfURL.lastPathComponent)")
                .font(.headline)
                .padding()
            
            PDFKitView(pdfURL: pdfURL)
        }
        .navigationTitle("PDF Viewer")
        .navigationBarTitleDisplayMode(.inline)
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
