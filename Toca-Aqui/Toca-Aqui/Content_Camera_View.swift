//
//  Content.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//



import SwiftUI
import PDFKit
import QuickLook
import MLXLLM
import MLXLMCommon
import SwiftData
/*
 struct Content_Camera_View: View {
 @State var recognisedText: String = "Tap the button to scan a document."
 @State var output: String = ""   // This will store the model-generated summary.
 @State private var pdfFile: PDFFile?
 @State private var showScanner: Bool = false
 @State private var isSheetOpen: Bool = false
 
 
 //Sheet Properties
 @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height * 0.9 - 100
 private var maxHeight: CGFloat { UIScreen.main.bounds.height * 0.9 }
 private let minHeight: CGFloat = 100
 private let bottomMargin: CGFloat = 30
 
 
 
 @Environment(\.modelContext) private var modelContext
 
 var body: some View {
 ZStack{
 NavigationView {
 VStack(spacing: 20) {
 // Display scanned text.
 // Button to launch scanner.
 Button(action: {
 showScanner = true
 }) {
 Image(systemName: "camera.fill")
 .resizable()
 .scaledToFit()
 .frame(width: 90, height: 90)
 .padding(.all, 48)
 .background{
 Circle()
 .fill(Color.white)
 .shadow(radius: 10)
 }
 .foregroundColor(.black)
 }
 
 }
 .padding()
 .navigationTitle("Document Scanner")
 // Present the scanner view.
 .sheet(isPresented: $showScanner) {
 ScanDocumentView(recognisedText: $recognisedText)
 }
 // When scanning is complete, automatically generate summary, PDF, and preview.
 .onChange(of: recognisedText) {_, newValue in
 guard newValue != "Tap the button to scan a document." else { return }
 Task {
 // Call your model's generate function (which updates output).
 try await generate(recognisedText: newValue, downloadProgress: .constant(1.0))
 // Wait to ensure output is updated.
 try await Task.sleep(nanoseconds: 1_000_000_000)
 print("Model output: \(output)")
 // Generate PDF from the model's summary.
 if let pdfURL = generatePDF(text: output) {
 try await Task.sleep(nanoseconds: 2_500_000_000)
 pdfFile = PDFFile(url: pdfURL)
 }
 }
 }
 // Present the QuickLook preview automatically when a valid PDF is available.
 .sheet(item: $pdfFile) { file in
 PreviewAndSavePDFView(fileURL: file.url, onSave: {
 storePDF(url: file.url, context: modelContext)
 })
 }
 
 }
 
 DraggableBottomSheet(
 offset: $sheetOffset,
 maxHeight: maxHeight,
 minHeight: minHeight,
 bottomMargin: bottomMargin
 ) {
 VStack(alignment: .leading, spacing: 8) {
 HStack {
 Text("Documents")
 .font(.headline)
 .foregroundColor(.white)
 .padding(.leading, 20)
 Spacer()
 Image(systemName: "text.document.fill")
 .padding(.trailing, 30)
 }
 
 Text("Documents")
 .foregroundColor(.white.opacity(0.7))
 .padding(.leading, 20)
 
 Divider()
 .background(Color.white.opacity(0.2))
 .padding(.horizontal, 20)
 
 ForEach(1...5, id: \.self) { i in
 Text("Saved PDF \(i)")
 .padding(.vertical, 4)
 .foregroundColor(.white)
 .padding(.horizontal, 20)
 }
 
 Spacer()
 }
 .padding(.top, 8)
 }
 }
 }
 }
 */


// MARK: - Content_Camera_View
struct Content_Camera_View: View {
    @State var recognisedText: String = "Tap the button to scan a document."
    @State var output: String = ""   // This will store the model-generated summary.
    @State private var pdfFile: PDFFile?
    @State private var showScanner: Bool = false
    // Bottom sheet state:
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height * 0.9 - 100
    
    private var maxHeight: CGFloat { UIScreen.main.bounds.height * 0.9 }
    private let minHeight: CGFloat = 100
    private let bottomMargin: CGFloat = 30
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 20) {
                    Button(action: {
                        showScanner = true
                    }) {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .padding(48)
                            .background {
                                Circle()
                                    .fill(Color.white)
                                    .shadow(radius: 10)
                            }
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .navigationTitle("Document Scanner")
                .sheet(isPresented: $showScanner) {
                    ScanDocumentView(recognisedText: $recognisedText)
                }
                .onChange(of: recognisedText) { _, newValue in
                    guard newValue != "Tap the button to scan a document." else { return }
                    Task {
                        // Call your model's generate function (which updates output).
                        try await generate(recognisedText: newValue, downloadProgress: .constant(1.0))
                        // Wait for output to update.
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        print("Model output: \(output)")
                        // Generate PDF from the model-generated summary.
                        if let pdfURL = generatePDF(text: output) {
                            try await Task.sleep(nanoseconds: 2_500_000_000)
                            pdfFile = PDFFile(url: pdfURL)
                        }
                    }
                }
                .sheet(item: $pdfFile) { file in
                    PreviewAndSavePDFView(fileURL: file.url, onSave: {
                        storePDF(url: file.url, context: modelContext)
                    })
                }
            }
            // Persistent bottom sheet showing the saved PDFs.
            DraggableBottomSheet(
                offset: $sheetOffset,
                maxHeight: maxHeight,
                minHeight: minHeight,
                bottomMargin: bottomMargin
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    // Header with "Documents" and the icon.
                    HStack {
                        Text("Documents")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        Spacer()
                        Image(systemName: "text.document.fill")
                            .padding(.trailing, 30)
                    }
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 20)
                    
                    // Show the list of saved PDFs.
                    SavedPDFsView()
                        .modelContainer(modelContext.container)
                }
                .padding(.top, 8)
            }
        }
    }
}


