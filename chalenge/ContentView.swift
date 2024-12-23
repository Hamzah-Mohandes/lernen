//
//  ContentView.swift
//  chalenge
//
//  Created by Hamzah on 19.11.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Hintergrundbild
            Image("background") // Ersetze "background" durch den tatsächlichen Namen deines Bildes
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer() // Platzhalter, um den unteren Bereich nach unten zu verschieben

                // Unterer Bereich
                VStack(spacing: 10) {
                    HStack {
                        Text("Good Afternoon, Jodie")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()

                        Text("12:55")
                            .font(.title3)
                            .foregroundColor(.white)
                    }

                    Text("It's Sunday")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("August 18th")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    HStack(spacing: 20) {
                        Image(systemName: "camera")
                            .foregroundColor(.white)
                        Image(systemName: "square.grid.2x2")
                            .foregroundColor(.white)
                        Image(systemName: "play.rectangle")
                            .foregroundColor(.white)
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
