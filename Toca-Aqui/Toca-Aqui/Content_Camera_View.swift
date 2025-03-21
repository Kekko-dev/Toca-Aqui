
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
    @State private var reducingText: Double = 0.0
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

    // New state variable for the breathing animation
    @State private var imageScale: CGFloat = 1.0

    var body: some View {
        NavigationView {
            ZStack {
                Color.church_purple_color
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.15)
                
                VStack(spacing: 20) {
                    Button(action: {
                        showScanner = true
                    }) {
                        Image("Camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .scaleEffect(imageScale) // Apply the scale effect here.
                            .padding()
                            .background {
                                Circle()
                                    .fill(Color.white)
                                    .opacity(0.35)
                                    .frame(width: 190, height: 190)
                                    .scaleEffect(imageScale)
                            }
                            // Start the breathing animation when the image appears.
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                    imageScale = 1.1
                                }
                            }
                    }
                }
                .fullScreenCover(isPresented: $showScanner) {
                    ScanDocumentView(recognisedText: $recognisedText,
                                     structuredText: $structuredText,
                                     onCancel: { showScanner = false })
                        .ignoresSafeArea()
                }
                .foregroundStyle(Color.church_purple_color)
                .padding()
                // Process the scanned text once recognisedText is updated.
                .onChange(of: recognisedText) { _, newValue in
                    if newValue != "Tap the button to scan a document." {
                        Task {

                            
                                isDownloading = true
                                downloadProgress = 0.0
                                statusMessage = "Origo is preparing the system"
                            
                            
                            // Phase 1: Download the model.
                            try await generate(structuredText: structuredText,
                                                 downloadProgress: $downloadProgress)
                            

                            
                                downloadProgress = 0.0
                                statusMessage = "Origo is making your text accessible"
                            
                            
                            // Phase 2: Create the PDF.
                            if let pdfURL = generateStructuredPDF(textSections: structuredText, documentName: "Origo", documentDate: Date(), logo: UIImage(contentsOfFile: "Logo_Purple") ) {
                                for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                                    
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
                    .interactiveDismissDisabled(true)
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
                                    .foregroundColor(Color.church_purple_color)
                                    .padding(.leading, 20)
                                Spacer()
                                Button(action: {
                                    sheetOffset = -maxHeight + 750
                                }) {
                                    Image("Bell")
                                        .font(.title) // adjust as needed
                                }
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
            .foregroundStyle(Color.church_purple_color)
        }
        .tint(Color.church_purple_color)
    }
}


extension Color {
    static let church_purple_color: Color = Color(red: 134/255, green: 59/255, blue: 158/255)
    static let church_red_color: Color = Color(red: 239/255, green: 28/255, blue: 25/255)
    static let church_green_color: Color = Color(red: 88/255, green: 187/255, blue: 134/255)

}


extension UIColor {
    static let church_purple_color: UIColor = UIColor(red: 134/255, green: 59/255, blue: 158/255, alpha: 1.0)
    static let church_red_color: UIColor = UIColor(red: 239/255, green: 28/255, blue: 25/255, alpha: 1.0)
    static let church_green_color: UIColor = UIColor(red: 88/255, green: 187/255, blue: 134/255, alpha: 1.0)

}
