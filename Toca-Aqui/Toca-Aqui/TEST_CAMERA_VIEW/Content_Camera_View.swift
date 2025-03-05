//import SwiftUI
//import AVFoundation
//import Vision
//
//struct Content_Camera_View: View {
//    @Binding var showingSheet: Bool
//    @State private var recognizedText: String = "Scan for text"
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            ScannerView(recognizedText: $recognizedText)
//                .edgesIgnoringSafeArea(.all)
//                .onAppear {
//                    showingSheet = false
//                }
//                .onDisappear {
//                    showingSheet = true
//                }
//
//            Text(recognizedText)
//                .padding()
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .padding(.bottom, 70)
//        }
//    }
//}
//
//#Preview {
//    Content_Camera_View(showingSheet: .constant(true))
//}
