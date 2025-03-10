//
//  SavedPDF_View.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 06/03/25.
//


import SwiftUI
import SwiftData


struct SavedPDFsView: View {
    @Query var savedPDFs: [SavedPDF] //Fetches all saved PDFs from SwiftData.
    
    @Environment(\.modelContext) private var modelContext //Provides access to the SwiftData database for deleting PDFs.
    
    @State private var selectedPDF: URL? //Stores the selected PDF’s file path (used when opening a PDF).
    
    @State private var showPDFViewer = false  //Controls whether the PDF viewer should be shown. --> NEEDS TO BE DELETED
    
    @State private var isLoading = false //Tracks whether a PDF is loading, showing a loading indicator. --> DEBUGGING
    

    var body: some View {
        NavigationView {
            
           List {
                
                
                ForEach(savedPDFs) { pdf in
                    Button(action: {
                        
                            isLoading = true // Start loading
                        
                            selectedPDF = pdf.filePath // Crucial to find the pdf
                            showPDFViewer = true
                        
                            isLoading = false // Stop loading
                        
                    }) {
                        HStack { //Information about the file --> NEEDS TO BE UPGRADED
                            VStack(alignment: .leading) {
                                Text(pdf.fileName)
                                    .font(.headline)
                                Text("Saved on: \(formattedDate(pdf.dateCreated))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onDelete { indexSet in //Removes the selected PDF from SwiftData BUT doesn't delete it from the Storage, only from the list
                    for index in indexSet {
                        modelContext.delete(savedPDFs[index])
                        if FileManager.default.fileExists(atPath: savedPDFs[index].filePath.path) {
                            try? FileManager.default.removeItem(at: savedPDFs[index].filePath)
                        }
                    }
                }
            }
            .overlay(
                isLoading ? ProgressView("Loading PDF...").padding().background(Color.white).cornerRadius(10) : nil
            )
            //.navigationTitle("Saved PDFs")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showPDFViewer) {
                if let pdfURL = selectedPDF {
                    PDFViewer(pdfURL: pdfURL)
                }
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    SavedPDFsView()
}
