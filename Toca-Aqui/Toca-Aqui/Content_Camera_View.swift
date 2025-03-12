
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
    @State var output: String = ""   // Model-generated summary.
    @State private var pdfFile: PDFFile?
    
    // States for loading & progress.
    @State private var downloadProgress: Double = 0.0
    @State private var isDownloading: Bool = false
    @State private var statusMessage: String = "Downloading the Model"
    
    // State for presenting the scanner.
    @State private var showScanner: Bool = false

    // Bottom sheet state:
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height * 0.9 - 100
    private var maxHeight: CGFloat { UIScreen.main.bounds.height * 0.9 }
    private let minHeight: CGFloat = 100
    private let bottomMargin: CGFloat = 30

    @State var documentName: String = ""
    @State var structuredText: [(text: String, isTitle: Bool)] = []

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            ZStack {
                Color.purple
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.1)
                
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
                    }
                }
                .fullScreenCover(isPresented: $showScanner) {
                            ScanDocumentView(recognisedText: $recognisedText,
                                             structuredText: $structuredText,
                                             onCancel: { showScanner = false })
                            .ignoresSafeArea()
                        }
                .foregroundStyle(.purple)
                .padding()
                // Process the scanned text once recognisedText is updated.
                .onChange(of: recognisedText) { newValue in
                    if newValue != "Tap the button to scan a document." {
                        Task {
                            await MainActor.run {
                                isDownloading = true
                                downloadProgress = 0.0
                                statusMessage = "Downloading the Model"
                            }
                            
                            // Phase 1: Download the model.
                            try await generate(structuredText: structuredText,
                                                 downloadProgress: $downloadProgress)
                            
                            await MainActor.run {
                                downloadProgress = 1.0
                                statusMessage = "Creating pdf"
                            }
                            
                            // Phase 2: Create the PDF.
                            if let pdfURL = generateStructuredPDF(textSections: structuredText) {
                                for progress in stride(from: 1.0, through: 2.0, by: 0.1) {
                                    
                                        downloadProgress = progress
                                    
                                    try await Task.sleep(nanoseconds: 300_000_000)
                                }
                                
                                
                                    pdfFile = PDFFile(url: pdfURL)
                                
                            }
                            
                           
                                isDownloading = false
                            
                        }
                    }
                }
                // Present the generated PDF.
                .sheet(item: $pdfFile) { file in
                    PreviewAndSavePDFView(fileURL: file.url, onSave: { _ in
                        storePDF(url: file.url,
                                 fileName: documentName,
                                 context: modelContext)
                    }, documentName: $documentName)
                }
                
                // Loading overlay.
                if isDownloading {
                    LoadingScreen(isDownloading: $isDownloading,
                                  downloadProgress: $downloadProgress,
                                  statusMessage: $statusMessage)
                }
                
                // Show the bottom sheet only when the scanner is not shown.
                if !showScanner {
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
                                    .foregroundColor(.black)
                                    .padding(.leading, 20)
                                Spacer()
                                Image(systemName: "book")
                                    .padding(.trailing, 30)
                                    .containerShape(Circle())
                            }
                            SavedPDFsView()
                                .modelContainer(modelContext.container)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .foregroundStyle(.purple)
        }
        // Present the scanner as a full-screen view.
    }
}
