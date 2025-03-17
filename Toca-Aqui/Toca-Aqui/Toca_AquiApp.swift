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

    init() {
        do {
            let schema = Schema([SavedPDF.self])
            sharedModelContainer = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(sharedModelContainer)
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
