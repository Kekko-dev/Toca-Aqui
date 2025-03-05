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
            HStack {
                Text("Daily Missals")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                
                Image(systemName: "books.vertical.fill")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 20)
            }

            Text("0 Files")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            VStack{
                List {
                    Label("Daily Missals", systemImage: "folder.fill")
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .listStyle(.automatic)
                
                Text("Daily Missals")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    SheetView()
}
