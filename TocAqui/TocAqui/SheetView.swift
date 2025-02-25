//
//  SheetView.swift
//  TocAqui
//
//  Created by Iago Xavier de Lima on 24/02/25.
//
import SwiftUI

struct SheetView: View {
    var body: some View {
        VStack {
            
            
                Text("Daily Missals")
                .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)

                Text("0 Files")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)

            List{
                Label("Daily Missals", systemImage: "folder.fill")
                
            }.listStyle(.plain)
            
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SheetView()
}
