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
                LottieViewRepresentable(animation: .named("documentAnim")!)
                    .frame(width: 50, height: 50)
                    .scaleEffect(0.10)
                    .scaledToFill()
                    .padding()
                Spacer()
                /*Text("Origo is doing the magic...")
                    .font(.title) // Imposta lo stile del testo come 'title'
                    .fontWeight(.bold)
                Text("\(statusMessage) \(Int(downloadProgress*100))%")
                    .font(.title2)
                */
                Text("\(statusMessage)")
                    .font(.title) // Imposta lo stile del testo come 'title'
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text("\(Int(downloadProgress*100))%")
                    .font(.title) // Imposta lo stile del testo come 'title'
                    .fontWeight(.bold)
                ProgressView(value: downloadProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 40)
                    .tint(Color.church_purple_color)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                VisualEffectBlur(blurStyle: .systemMaterial)
                    .edgesIgnoringSafeArea(.all)
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}



struct LottieViewRepresentable: UIViewRepresentable {
    var animation: LottieAnimation
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(animation: animation)
        animationView.loopMode = .loop//anim va in  loop
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.play()// fa partire animaz con l'appariz della view
    }
}

struct BlurredBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                VisualEffectBlur(blurStyle: .systemMaterial)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        //nothing
    }
}
