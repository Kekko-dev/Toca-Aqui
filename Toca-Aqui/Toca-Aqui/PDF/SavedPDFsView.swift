//
//  SavedPDF_View.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 06/03/25.
//

import SwiftUI
import SwiftData
import PDFKit

struct SavedPDFsView: View {
    @Query var savedPDFs: [SavedPDF]
    @Environment(\.modelContext) private var modelContext
    @State private var showRenameAlert = false
    @State private var newDocumentName = ""
    
    // Define a grid layout.
    let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 16)
    ]
    
    var body: some View {
        
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(savedPDFs) { pdf in
                        NavigationLink(destination: PDFViewer(pdfURL: pdf.filePath)) {
                            VStack {
                                PDFThumbnailView(pdfURL: pdf.filePath)
                                Text(pdf.fileName)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            
                            
                            
                        }
                       
                        
                        
                        
                        .contextMenu {
                            // Delete action.
                            Button(role: .destructive) {
                                delete(pdf: pdf)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            // Rename action.
                            Button {
                                newDocumentName = pdf.fileName
                                showRenameAlert = true
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            
                            // Share action.
                            Button {
                                share(pdf: pdf)
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                }
                .padding()
            }
            

            
            // Alert for renaming.
            .alert("Rename Document", isPresented: $showRenameAlert, actions: {
                TextField("New Name", text: $newDocumentName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    renameDocument(newName: newDocumentName)
                }
            })
        
    }
    
    private func delete(pdf: SavedPDF) {
        modelContext.delete(pdf)
        if FileManager.default.fileExists(atPath: pdf.filePath.path) {
            try? FileManager.default.removeItem(at: pdf.filePath)
        }
    }
    
    private func renameDocument(newName: String) {
        guard savedPDFs.firstIndex(where: { $0.fileName == newName }) == nil else {
            print("A document with this name already exists.")
            return
        }
        
        // Find the PDF to rename.
        if let pdf = savedPDFs.first(where: { $0.fileName == newDocumentName }) {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let newURL = documentsDirectory.appendingPathComponent(newName)
            do {
                try FileManager.default.moveItem(at: pdf.filePath, to: newURL)
                pdf.fileName = newName
                pdf.filePathString = newURL.path
            } catch {
                print("Error renaming PDF: \(error)")
            }
        }
    }
    
    private func share(pdf: SavedPDF) {
        guard let url = URL(string: pdf.filePath.path) else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }
}
#Preview {
    SavedPDFsView()
}


import SwiftUI
import PDFKit

struct PDFThumbnailView: View {
    let pdfURL: URL
    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.purple
                    .opacity(0.3)
                    .overlay(ProgressView())
                    .onAppear(perform: generateThumbnail)
            }
        }
        .frame(width: 100, height: 140) // Adjust size as needed
        .cornerRadius(8)
        .shadow(radius: 2)
    }
    
    private func generateThumbnail() {
        DispatchQueue.global(qos: .background).async {
            print("Attempting to load PDF from: \(pdfURL)")
            guard let document = PDFDocument(url: pdfURL) else {
                print("Failed to load PDF document!")
                return
            }
            if let page = document.page(at: 0) {
                let thumb = page.thumbnail(of: CGSize(width: 100, height: 140), for: .cropBox)
                DispatchQueue.main.async {
                    thumbnail = thumb
                    print("Thumbnail generated successfully.")
                }
            } else {
                print("No page found in PDF.")
            }
        }
    }
}


