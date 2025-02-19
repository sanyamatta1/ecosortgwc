//
//  WelcomeView.swift
//  EcoSort
//
//  Created by sanya matta on 10/20/24.
//

import Foundation
import SwiftUI


struct WelcomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("loginbackground")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Welcome Text
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Welcome to EcoSort")
                            .font(.custom("Times New Roman", size: 42)) // Times New Roman font
                            .fontWeight(.bold)  // Bold for EcoSort text
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 50)  // Padding from the top
                            .padding(.horizontal, 20)  // Padding from the left

                        // "Your journey..." Text
                        Text("Your journey towards sustainable waste management")
                            .font(.custom("Times New Roman", size: 22)) // Times New Roman font
                            .fontWeight(.medium)  // Medium weight for less thickness
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)  // Aligns text to the left with padding
                    }

                    Spacer()

                    // Get Started Button, styled like Sign Out button
                    NavigationLink(destination: SignInView()) {
                        Text("Get Started")
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#DACFBB")) // Soft Sand Color
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)  // Centered with horizontal padding
                    .padding(.bottom, 50)      // Push it to the bottom
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
