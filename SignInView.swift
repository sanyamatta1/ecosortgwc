//
//  SignInView.swift
//  EcoSort
//
//  Created by sanya matta on 9/25/24.
//


import Foundation
import SwiftUI


struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            // Background Image
            Image("loginbackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // Floating card with form
            VStack {
                Spacer()

                VStack(spacing: 25) {
                    Text("Sign In")
                        .font(.custom("Times New Roman", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    // Email Input
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color(hex: "#154F39"))  // Dark green color
                        TextField("E-mail", text: $email)
                            .autocapitalization(.none)
                            .padding(.leading, 5)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))  // Adjusted opacity for more transparency
                    .cornerRadius(10)
                    
                    // Password Input
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color(hex: "#154F39"))  // Dark green color
                        SecureField("Password", text: $password)
                            .padding(.leading, 5)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))  // Adjusted opacity for more transparency
                    .cornerRadius(10)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }

                    // Sign In Button
                    Button(action: {
                        signIn()
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#154F39"))  // Dark green button color
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    // Create a new account link
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Create one")
                            .font(.footnote)
                            .foregroundColor(Color(hex: "#154F39"))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 40)
                .background(Color.white.opacity(0.8))  // Adjusted opacity for more transparency
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationBarHidden(true)  // Hide back button for clean design
    }

    func signIn() {
        authViewModel.signIn(email: email, password: password) { success in
            if !success {
                errorMessage = authViewModel.errorMessage
            } else {
                errorMessage = nil
            }
        }
    }
}
