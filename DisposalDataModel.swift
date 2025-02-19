//
//  DisposalDataModel.swift
//  EcoSort
//
//  Created by sanya matta on 9/23/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DisposalDataModel: ObservableObject {
    @Published var oldEntries: [(itemName: String, disposalMethod: String, quantity: String, quantityType: String, date: Date)] = []

    private var db = Firestore.firestore()
    private var userID: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        // Automatically fetch data when initialized if the user is signed in
        if userID != nil {
            fetchData()
        }
    }

    // Fetch data from Firestore for the current user
    func fetchData() {
        guard let userID = userID else { return }

        db.collection("users").document(userID).collection("disposalEntries").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                self?.oldEntries = snapshot.documents.compactMap { document in
                    let data = document.data()
                    guard let itemName = data["itemName"] as? String,
                          let disposalMethod = data["disposalMethod"] as? String,
                          let quantity = data["quantity"] as? String,
                          let quantityType = data["quantityType"] as? String,
                          let timestamp = data["date"] as? Timestamp else { return nil }
                    let date = timestamp.dateValue()
                    return (itemName, disposalMethod, quantity, quantityType, date)
                }
            }
        }
    }

    // Save a new entry to Firestore
    func addEntry(itemName: String, disposalMethod: String, quantity: String, quantityType: String, date: Date) {
        guard let userID = userID else {
            print("Error: User ID not found.")
            return
        }

        let newEntry = [
            "itemName": itemName,
            "disposalMethod": disposalMethod,
            "quantity": quantity,
            "quantityType": quantityType,
            "date": Timestamp(date: date)
        ] as [String : Any]

        // Add to Firestore and print any errors
        db.collection("users").document(userID).collection("disposalEntries").addDocument(data: newEntry) { error in
            if let error = error {
                print("Error adding document to Firestore: \(error.localizedDescription)")
            } else {
                print("Document successfully added to Firestore")
                DispatchQueue.main.async {
                    self.oldEntries.append((itemName, disposalMethod, quantity, quantityType, date))
                }
            }
        }
    }


    // Delete an entry from Firestore
    func deleteEntry(entry: (itemName: String, disposalMethod: String, quantity: String, quantityType: String, date: Date)) {
        guard let userID = userID else { return }

        // Find the document ID based on a unique identifier (date here, assuming it's unique)
        db.collection("users").document(userID).collection("disposalEntries")
            .whereField("date", isEqualTo: Timestamp(date: entry.date))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error deleting entry: \(error.localizedDescription)")
                    return
                }

                snapshot?.documents.first?.reference.delete() // Delete the first document that matches
                self.oldEntries.removeAll { $0.date == entry.date }
            }
    }
}
