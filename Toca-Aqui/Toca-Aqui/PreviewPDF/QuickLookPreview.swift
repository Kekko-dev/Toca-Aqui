//
//  QuickLookPreview.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 07/03/25.
//

import SwiftUI
import UIKit
import QuickLook

// Wrapper for the PDF file (used with sheet(item:))
struct PDFFile: Identifiable {
    let id = UUID()
    let url: URL
}

// QuickLook Preview Wrapper (same as before)
struct QuickLookPreview: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        // Reload data after a short delay to ensure file metadata is updated.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            uiViewController.reloadData()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(fileURL: fileURL)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let fileURL: URL
        init(fileURL: URL) { self.fileURL = fileURL }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            fileURL as QLPreviewItem
        }
    }
}

// Preview view with a Save PDF button.
struct PreviewAndSavePDFView: View {
    let fileURL: URL
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                QuickLookPreview(fileURL: fileURL)
                    .edgesIgnoringSafeArea(.all)
                Button(action: {
                    onSave()
                    dismiss()
                }) {
                    Text("Save PDF")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("PDF Preview")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
