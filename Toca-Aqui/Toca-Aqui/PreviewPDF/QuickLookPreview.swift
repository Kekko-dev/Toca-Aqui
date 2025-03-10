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
    /// onSave now accepts the chosen document name.
    let onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    // State to hold the document name.
    @Binding var documentName: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TextField to enter the document name.
                TextField("Enter document name", text: $documentName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // The PDF preview.
                QuickLookPreview(fileURL: fileURL)
                    .edgesIgnoringSafeArea(.all)
            }
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    onSave(documentName)
                    dismiss()
                }
                // Disable Save if the name is empty or only whitespace.
                .disabled(documentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
}
