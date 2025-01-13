//
//  ContentView.swift
//  start to learn2025
//
//  Created by Hamzah on 10.01.25.
//

import SwiftUI
import SwiftUI

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome to SwiftUI!")
                .font(.title)
                .padding()

            HStack {
                Text("Left")
                    .padding()
                Spacer()
                Text("Right")
                    .padding()
            }
            .background(Color.gray.opacity(0.2))

            Button("Click Me") {
                print("Button clicked!")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
#Preview {
    
    ContentView()
   
    
}
