//
//  WelcomeView.swift
//  Origo
//
//  Created by Francesco Silvestro on 13/03/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            
            Color.church_purple_color
                .ignoresSafeArea()
                .opacity(0.1)
            
           
            VStack {
                Spacer()
                Image("Logo_Purple")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Image("Origo_Purple")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
            }
        }
    }
}
#Preview {
    WelcomeView()
}
