//
//  ContentView.swift
//  TabView-Lernen
//
//  Created by Hamzah on 17.11.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.8039215803, green: 0.5882352941, blue: 0.9019607843, alpha: 1)), Color(#colorLiteral(red: 0.662745098, green: 0.5137254902, blue: 0.8509803922, alpha: 1))]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Top Bar
                HStack {
                    Spacer()
                    Text("14:25")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "battery.100")
                        .foregroundColor(.white)
                    Image(systemName: "wifi")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Spacer().frame(height: 20)

                // Main Content
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text("Creativity")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                        Spacer()
                    }

                    ZStack {
                        Image("profile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "sparkles")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Session 294")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, 10)

                        Text("Abstract Arts")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)

                        HStack {
                            Image(systemName: "paintbrush.pointed")
                                .foregroundColor(.white)
                            Text("#Lesson1")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 10)

                        Text("The term subjects in art refers to the main idea that is represented in the artwork. The subject in art is basically the essence of the piece...")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.vertical, 5)

                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                            Text("Coach: @Ross_1994")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 10)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Cost")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text("x3,500")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Session Time")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text("2.5 Hours")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding()

                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
