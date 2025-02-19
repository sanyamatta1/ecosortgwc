import Foundation
import SwiftUI

// Struct to represent an item in the cart with its disposal category
struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let disposalCategory: String
}

class CartManager: ObservableObject {
    @Published var cartItems: [CartItem] = []  // Store CartItem objects instead of strings

    // Add item to the cart
    func addItem(_ item: CartItem) {
        cartItems.append(item)
    }

    // Remove item from the cart
    func removeItem(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }
}
