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
                LottieViewRepresentable(animation: .named("origoLoadAnim")!)
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
struct LottieViewRepresentable: UIViewRepresentable {
    var animation: LottieAnimation
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(animation: animation)
        animationView.loopMode = .loop//anim va in  loop
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.play()// fa partire animazione con l'apparizione della view
    }
}

#Preview {
    LoadingScreen(isDownloading: .constant(true),
                  downloadProgress: .constant(0.5),
                  statusMessage: .constant("Downloading the Model"))
}
