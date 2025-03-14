//
//  RootView.swift
//  Origo
//
//  Created by Francesco Silvestro on 13/03/25.
//

import SwiftUI


struct RootView: View {
    @State private var showWelcome = true

    var body: some View {
        Group {
            if showWelcome {
                WelcomeView()
                    .transition(.opacity)
            } else {
                Content_Camera_View()
            }
        }
        .onAppear {
            // Delay before switching to the main view (e.g., 3 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showWelcome = false
                }
            }
        }
    }
}
