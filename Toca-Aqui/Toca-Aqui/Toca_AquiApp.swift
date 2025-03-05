//
//  Toca_AquiApp.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 21/02/25.
//

import SwiftUI

@main
struct TocAquiApp: App {
    
    var body: some Scene {
        WindowGroup {
            Content_Camera_View(showScanner: .constant(true))
        }
    }
}
