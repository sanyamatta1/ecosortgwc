//
//  SignUpView.swift
//  EcoSort
//
//  Created by sanya matta on 9/25/24.
//

import Foundation
import SwiftUI


struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Background Image
            Image("loginbackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // Sign Up Card
                VStack(spacing: 25) {

                    // Back Button and Sign Up Text in the same row
                    HStack {
                        // Back Button to Sign In
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()  // Go back to Sign In view
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(Color(hex: "#154F39"))  // Dark green color
                                .font(.system(size: 20, weight: .bold))  // Bold and larger arrow
                                .padding(.trailing, 10)
                        }

                        Spacer()

                        Text("Sign Up")
                            .font(.custom("Times New Roman", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.leading, -20)  // Adjust this to shift text closer to the back button
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // Email Input
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color(hex: "#154F39"))  // Dark green color
                        TextField("E-mail", text: $email)
                            .autocapitalization(.none)
                            .padding(.leading, 5)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))  // Slight transparency for the card
                    .cornerRadius(10)

                    // Password Input
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color(hex: "#154F39"))  // Dark green color
                        SecureField("Password", text: $password)
                            .padding(.leading, 5)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }

                    // Sign Up Button
                    Button(action: {
                        signUp()
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#154F39"))  // Dark green button color
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    // Already have an account link
                    NavigationLink(destination: SignInView()) {
                        Text("Already have an account? Sign In")
                            .font(.footnote)
                            .foregroundColor(Color(hex: "#154F39"))  // Dark green text
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 40)
                .background(Color.white.opacity(0.8))  // Same white block styling
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationBarHidden(true)  // Hide navigation bar
    }

    func signUp() {
        authViewModel.signUp(email: email, password: password) { success in
            if !success {
                errorMessage = authViewModel.errorMessage
            } else {
                errorMessage = nil
                presentationMode.wrappedValue.dismiss()  // Dismiss on success
            }
        }
    }
}
