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

struct Content_Camera_View: View {
    @State var recognisedText: String = "Tap the button to scan a document."
    @State var output: String = ""   // Store model-generated summary
    @State private var pdfFile: PDFFile?
    @State private var showScanner: Bool = false
    @State private var downloadProgress: Double = 0.0  // Stato per la barra di progresso

    // Bottom sheet state
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height * 0.9 - 100
    private var maxHeight: CGFloat { UIScreen.main.bounds.height * 0.9 }
    private let minHeight: CGFloat = 100
    private let bottomMargin: CGFloat = 30
    
    @State var documentName: String = ""
    @State var structuredText: [(text: String, isTitle: Bool)] = []

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
                    //progress bar for the model download
                    if downloadProgress > 0.0 && downloadProgress < 1.0 {
                        VStack {
                            Text("Downloading model...")
                                .font(.caption)
                            ProgressView(value: downloadProgress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding(.horizontal, 40)
                        }
                    }
                }
                .padding()
                .sheet(isPresented: $showScanner) {
                    ScanDocumentView(recognisedText: $recognisedText, structuredText: $structuredText)
                }
                .onChange(of: recognisedText) { _, newValue in
                    guard newValue != "Tap the button to scan a document." else { return }
                    Task {
                        // Chiamata alla funzione con il binding della progress bar
                        try await generate(structuredText: structuredText, downloadProgress: $downloadProgress)
                        print("Model output: \(output)")
                        
                        // Generazione PDF dopo la sintesi
                        if let pdfURL = generateStructuredPDF(textSections: structuredText) {
                            try await Task.sleep(nanoseconds: 2_500_000_000)
                            pdfFile = PDFFile(url: pdfURL)
                        }
                    }
                }
                .sheet(item: $pdfFile) { file in
                    PreviewAndSavePDFView(fileURL: file.url, onSave: {_ in
                        storePDF(url: file.url, fileName: documentName, context: modelContext)
                    }, documentName: $documentName)
                }
            }
            
            // Persistent bottom sheet showing saved PDFs
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
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 20)
                    SavedPDFsView()
                        .modelContainer(modelContext.container)
                }
                .padding(.top, 8)
            }
        }
    }
}
