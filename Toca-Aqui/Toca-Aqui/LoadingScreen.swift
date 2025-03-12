//
//  LoadingScreen.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 12/03/25.
//
import SwiftUI

struct LoadingScreen: View {
    @Binding var isDownloading: Bool
    @Binding var downloadProgress: Double
    @Binding var statusMessage: String
    
    var body: some View {
        if isDownloading {
            VStack(spacing: 8) {
                Text(statusMessage)
                    .font(.caption)
                ProgressView(value: downloadProgress, total: 2.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.8))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    LoadingScreen(isDownloading: .constant(true),
                  downloadProgress: .constant(0.5),
                  statusMessage: .constant("Downloading the Model"))
}
