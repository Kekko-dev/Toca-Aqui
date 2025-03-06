//
//  Toca_AquiApp.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//

import SwiftUI
import SwiftData

@main
struct TocAquiApp: App {
    var sharedModelContainer: ModelContainer
    /*
     Creates a shared SwiftData container.
     This stores all saved PDFs.
     It is accessible throughout the app.
     */

    init() {
        do {
            let schema = Schema([SavedPDF.self]) //Registers the SavedPDF model so SwiftData knows what data to store.
            sharedModelContainer = try ModelContainer(for: schema) // Creates the database container.
        } catch {
            fatalError(" Failed to initialize SwiftData: \(error)") // If SwiftData fails to load, the app crashes with an error message.
        }
    }

    var body: some Scene {
        WindowGroup {
            Content_Camera_View()
                .modelContainer(sharedModelContainer) // Makes database accessible throughout the app.
        }
    }
}


/*
 
 GENERAL STEPS TO IMPLEMENT SwiftData:
 
 CREATION:
 
 1) Create a SwiftData model : SavedPDF
 
 2) Create a ModelContainer in the main
 
 3) Use this initializer
 
 4) Injects SwiftData into the app:  .modelContainer(sharedModelContainer)
 
 
 USAGE:
 
 1) @Query to fetch the changes automatically: @Query var savedPDFs: [SavedPDF]
 
 2) @Environment(\.modelContext) private var modelContext --> Provide access to the SwiftData context inside the view
 
 2.1) modelContext.delete(container) --> delete
 2.2) modelContext.insert(container) --> insert
 
 */
