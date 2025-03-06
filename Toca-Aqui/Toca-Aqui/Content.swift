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

                // Aggiungi la ProgressBar per il download
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
                }
                .padding()
            }
            .navigationTitle("Document Scanner")
            .sheet(isPresented: $showScanner) {
                
                ScanDocumentView(recognisedText: $recognisedText)
            }
           
            .onChange(of: recognisedText) { newText in
                Task {
                    try await generate(recognisedText: newText, downloadProgress: $downloadProgress) 
                }
            }
        }
    }
}
