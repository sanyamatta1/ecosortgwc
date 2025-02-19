//
//  AuthViewModel.swift
//  EcoSort
//
//  Created by sanya matta on 9/25/24.
//

import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User? // Firebase User object
    @Published var isSignedIn: Bool = false
    @Published var errorMessage: String? = nil

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isSignedIn = user != nil
            }
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        if !isValidEmail(email) {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a valid email address"
            }
            completion(false)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                print("Sign up error: \(error.localizedDescription)")  // Add logging here
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = nil
                    self?.user = result?.user
                    self?.isSignedIn = true
                }
                completion(true)
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        if !isValidEmail(email) {
            DispatchQueue.main.async {
                self.errorMessage = "Please enter a valid email address"
            }
            completion(false)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                print("Sign in error: \(error.localizedDescription)")  // Add logging here
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = nil
                    self?.user = result?.user
                    self?.isSignedIn = true
                }
                completion(true)
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
                self.user = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
}
