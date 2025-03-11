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

// Preview view with an embedded text field for the document name.
struct PreviewAndSavePDFView: View {
    let fileURL: URL
    let onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @Binding var documentName: String
    
    var body: some View {
        NavigationView {
            QuickLookPreview(fileURL: fileURL)
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Place the text field in the middle of the navigation bar.
                    ToolbarItem(placement: .principal) {
                        TextField("Enter document name", text: $documentName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 300)
                    }
                    // Cancel button on the left.
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    // Save button on the right.
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            onSave(documentName)
                            dismiss()
                        }
                        .disabled(documentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
