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
                
                HStack {
                    Button(action: { showScanner = true }) {
                        Label("Scan Document", systemImage: "camera.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: saveText) {
                        Label("Save", systemImage: "square.and.arrow.down.fill")
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Document Scanner")
            .sheet(isPresented: $showScanner) {
                ScanDocumentView(recognisedText: $recognisedText)
            }
        }
    }

    func saveText() {
        let filename = FileManager.default.temporaryDirectory.appendingPathComponent("ScannedText.txt")
        do {
            try recognisedText.write(to: filename, atomically: true, encoding: .utf8)
            print("Saved to \(filename)")
        } catch {
            print("Failed to save text: \(error.localizedDescription)")
        }
    }
}
