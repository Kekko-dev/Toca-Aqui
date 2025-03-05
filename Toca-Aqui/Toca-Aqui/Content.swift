//
//  Content.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//

import SwiftUI

struct Content_Camera_View: View {
    @State private var recognisedText = "Tap the button below to scan a document."
    @Binding var showScanner: Bool
    @State private var summaryText = "Your summary will appear here."
    // Alternatively, use one output variable for clarity:
    @State var output: String = ""
    
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
                // Pass the recognisedText as a binding to update it directly from the scanner view.
                ScanDocumentView(recognisedText: $recognisedText)
            }
            // Automatically trigger summary generation whenever recognisedText changes.
            .onChange(of: recognisedText) { newText in
                Task {
                    try await generate(recognisedText: newText)
                }
            }
        }
    }
}
