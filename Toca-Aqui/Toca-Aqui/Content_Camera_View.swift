
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
    @State private var showScanner: Bool = false
    
    // New states for loading & progress.
    @State private var downloadProgress: Double = 0.0
    @State private var isDownloading: Bool = false
    @State private var statusMessage: String = "Downloading the Model"
    
    // Bottom sheet state:
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
                    .foregroundStyle(.purple)
                    .padding()
                    .sheet(isPresented: $showScanner) {
                        ScanDocumentView(recognisedText: $recognisedText,
                                         structuredText: $structuredText)
                    }
                    .onChange(of: recognisedText) { _, newValue in
                        guard newValue != "Tap the button to scan a document." else { return }
                        Task {
                            // Start the process.
                            await MainActor.run {
                                isDownloading = true
                                downloadProgress = 0.0
                                statusMessage = "Downloading the Model"
                            }
                            
                            // Phase 1: Downloading the model.
                            // Assume generate() updates progress from 0.0 to near 0.5.
                            try await generate(structuredText: structuredText,
                                                 downloadProgress: $downloadProgress)
                            
                            // After the model is downloaded, force progress to 0.5.
                            await MainActor.run {
                                downloadProgress = 1.0
                                statusMessage = "Creating pdf"
                            }
                            
                            // Phase 2: Creating the PDF.
                            if let pdfURL = generateStructuredPDF(textSections: structuredText) {
                                // Simulate PDF generation progress from 0.5 to 1.0.
                                for progress in stride(from: 1.0, through: 2.0, by: 0.1) {
                                    await MainActor.run {
                                        downloadProgress = progress
                                    }
                                    try await Task.sleep(nanoseconds: 300_000_000)
                                }
                                
                                await MainActor.run {
                                    pdfFile = PDFFile(url: pdfURL)
                                }
                            }
                            
                            await MainActor.run {
                                isDownloading = false
                            }
                        }
                    }
                    .sheet(item: $pdfFile) { file in
                        PreviewAndSavePDFView(fileURL: file.url, onSave: { _ in
                            storePDF(url: file.url,
                                     fileName: documentName,
                                     context: modelContext)
                        }, documentName: $documentName)
                    }
                }
            }
            
            // Show the loading overlay when isDownloading is true.
            if isDownloading {
                LoadingScreen(isDownloading: $isDownloading,
                              downloadProgress: $downloadProgress,
                              statusMessage: $statusMessage)
            }
            
            // Persistent bottom sheet showing saved PDFs.
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
        .foregroundStyle(.purple)
    }
}
