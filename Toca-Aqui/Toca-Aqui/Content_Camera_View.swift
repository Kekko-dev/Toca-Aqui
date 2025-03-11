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
    @State var output: String = ""   // This will store the model-generated summary.
    @State private var pdfFile: PDFFile?
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
        ZStack {
            Color.purple.ignoresSafeArea()
                .zIndex(-20)
            
            NavigationStack {
                ZStack {
                    Color.purple.edgesIgnoringSafeArea(.all)
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
                                .foregroundStyle(.purple)
                            
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    
                    .sheet(isPresented: $showScanner) {
                        ScanDocumentView(recognisedText: $recognisedText, structuredText: $structuredText)
                    }
                    
                    
                    .onChange(of: recognisedText) { _, newValue in
                        guard newValue != "Tap the button to scan a document." else { return }
                        Task {
                            // Call your summarization model function using the structured text.
                            try await generate(structuredText: structuredText, downloadProgress: .constant(1.0))
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                            print("Model output: \(output)")
                            // Generate a PDF using the structured text (which preserves titles and paragraphs).
                            if let pdfURL = generateStructuredPDF(textSections: structuredText) {
                                try await Task.sleep(nanoseconds: 2_500_000_000)
                                pdfFile = PDFFile(url: pdfURL)
                            }
                        }
                    }
                    .sheet(item: $pdfFile) { file in
                        PreviewAndSavePDFView(fileURL: file.url, onSave: {_ in
                            storePDF(url: file.url,fileName: documentName, context: modelContext)
                        }, documentName: $documentName)
                    }
                }
            }
            
            .background(.purple)
            .ignoresSafeArea()
            
            
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
                            .foregroundColor(.black)
                            .padding(.leading, 20)
                        Spacer()
                        Image(systemName: "book")
                            .padding(.trailing, 30)
                        // .frame(width: 10, height: 10)
                            .containerShape(.circle)
                        //.imageScale(.small)
                    }
                    
                    // Show the list of saved PDFs.
                    SavedPDFsView()
                        .modelContainer(modelContext.container)
                }
                .padding(.top, 8)
            }
            .foregroundStyle(.purple)
        }
       
        
    }
}


