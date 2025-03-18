//
//  LoadingScreen.swift
//  Toca-Aqui
//
//  Created by Francesco Silvestro on 12/03/25.
//
import SwiftUI

import Lottie

struct LoadingScreen: View {
    @Binding var isDownloading: Bool
    @Binding var downloadProgress: Double
    @Binding var statusMessage: String
    
    @State private var animationView = LottieAnimationView()//var per l'anim
    
    var body: some View {
        if isDownloading {
            VStack(spacing: 15) {
         Spacer()
                LottieViewRepresentable(animationName: "mshk-image-to-lottie")
                    .frame(width: 50, height: 50)  // Aggiungiamo un frame per ridurre la dimensione
                                        .scaleEffect(0.05)  // Ulteriore riduzione delle dimensioni
                                        .scaledToFill()
                                        .padding()
            
                                    
                Text("\(statusMessage) \(Int(downloadProgress*100))%")
                    .font(.caption)
                

                 ProgressView(value: downloadProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 40)
                    .tint(Color.church_purple_color)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.8))
            .edgesIgnoringSafeArea(.all)
        }
    }
}


/*I need to use LottieViewRepresentable e not LottieView simply
 because the second one in not integrated in SwwiftUI*/
import SwiftUI
import Lottie

struct LottieViewRepresentable: UIViewRepresentable {
    // Define a property for the animation name.
    var animationName: String
    var bundle: Bundle = .main

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        // Safely attempt to load the animation.
        if let animation = LottieAnimation.named(animationName, bundle: bundle) {
            animationView.animation = animation
            animationView.loopMode = .loop
            animationView.play()
        } else {
            print("Error: Animation named \(animationName) could not be loaded. Check the file name and target membership.")
        }
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }
}

// Preview Provider for testing in Xcode's canvas.
struct LottieViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        LottieViewRepresentable(animationName: "mshk-image-to-lottie")
            .frame(width: 50, height: 50)
    }
}
