//
//  ContentView.swift
//  TocAqui
//
//  Created by Francesco Silvestro on 20/02/25.
//
import SwiftUI

struct ContentView: View {
    @State private var showingSheet: Bool = true

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink(destination: Content_Camera_View(showingSheet: $showingSheet)) {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(.all, 48)
                        .background {
                            Circle()
                                .fill(Color.white)
                                .shadow(radius: 10)
                        }
                        .foregroundColor(.black)
                }
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity)
            .background {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea(edges: .all)
            }
            .sheet(isPresented: $showingSheet) {
                SheetView()
                    .interactiveDismissDisabled()
                    .presentationDetents([.fraction(0.1), .large])
                    .presentationBackgroundInteraction(.enabled)
                    .presentationBackground(.bar)
            }
        }
    }
}

#Preview {
    ContentView()
}
