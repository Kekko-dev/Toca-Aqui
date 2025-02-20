import SwiftUI
import AVFoundation
import Vision

// 1. Application main interface
struct Content_Camera_View: View {
    
    @State private var recognizedText: String = "Scan for text"
    
    var body: some View {
        ZStack(alignment: .bottom) {	
            ScannerView(recognizedText: $recognizedText)
                .edgesIgnoringSafeArea(.all)
            
            Text(recognizedText)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
        }
    }
}



#Preview {
    Content_Camera_View()
}
