//
//  Content.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//

import SwiftUI

struct Content_Camera_View: View {
    @State private var recognisedText = "Tap the button below to scan a document."
    @State private var showScanner = false
    @State private var summaryText = "Your summary will appear here."
    @State var output: String = ""
    
    @Environment(\.modelContext) private var modelContext
    @State private var showSavedPDFs = false
    
    @State private var downloadProgress: Double = 0.0  //var per la progress bar
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text(recognisedText)
                        .padding()
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding()
                }
                
                // Display the generated summary
                ScrollView {
                    Text(output)
                        .padding()
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding()
                        .foregroundColor(.blue)
                }
                
                // Progress bar for downloading the model
                if downloadProgress < 1.0 {
                    ProgressView("Downloading Model: \(Int(downloadProgress * 100))%", value: downloadProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                }
                
                HStack {
                    Button(action: { showScanner = true }) {
                        Label("Scan Document", systemImage: "camera.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        saveAsPDF(text: output, context: modelContext)
                    }) {
                        Label("Save as PDF", systemImage: "doc.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    Button(action: { showSavedPDFs = true }) {
                        Label("View Saved PDFs", systemImage: "folder.fill")
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Document Scanner")
            .sheet(isPresented: $showScanner) {
                
                ScanDocumentView(recognisedText: $recognisedText)
            }
            .sheet(isPresented: $showSavedPDFs) {
                SavedPDFsView()
                    .modelContainer(modelContext.container) // Ensure context is passed
            }
            
            .onChange(of: recognisedText) { newText in
                Task {
                    try await generate(recognisedText: newText, downloadProgress: $downloadProgress)
                }
            }
        }
    }
}
