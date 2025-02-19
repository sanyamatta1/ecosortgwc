import SwiftUI
import CoreLocation

struct b1Disposal: View {
    var itemName: String // The name of the item
    var displayText: String // The disposal method
    var nearbyLocations: [DisposalLocation] // Nearby disposal locations

    @EnvironmentObject var cartManager: CartManager
    @State private var navigateToCart = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            // Display the item name and disposal method in a cleaner way
            VStack(spacing: 8) {
                Text(itemName)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text(displayText)
                    .font(.title2)
                    .foregroundColor(.gray)
            }

            Spacer(minLength: 20)

            // Display nearby locations if available
            if !nearbyLocations.isEmpty {
                Text("Nearby Locations for Disposal")
                    .font(.headline)
                    .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(nearbyLocations, id: \.name) { location in
                            DisposalLocationCard(location: location)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No nearby locations found.")
                    .font(.subheadline)
                    .padding(.top, 20)
            }

            Spacer()

            // Add item to cart button
            Button(action: {
                addItemToCart()
            }) {
                Text("Add Item to Cart")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#154F39")) // Use your dark green color
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Disposal Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            // View Cart button
            Button(action: {
                navigateToCart = true
            }) {
                Text("View Cart")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#DACFBB"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Navigation to the Cart page
            NavigationLink(
                destination: Cart(), // Navigate to your Cart view
                isActive: $navigateToCart
            ) {
                EmptyView()
            }
        }
        .padding(.bottom, 20)
        .navigationBarTitle("Disposal Info", displayMode: .inline)
    }

    // Function to add the item to the cart with checks and alerts
    private func addItemToCart() {
        let blockedCategories = ["General Trash", "Household Waste", "Unrecyclable Waste"]

        if blockedCategories.contains(displayText) {
            alertMessage = "No disposal location found for \(itemName). Please dispose of it through regular waste services or contact your local waste management."
            showingAlert = true
        } else {
            let cartItem = CartItem(name: itemName, disposalCategory: displayText)
            cartManager.addItem(cartItem)
            alertMessage = "\(itemName) added to the cart!"
            showingAlert = true
        }
    }
}

// Card view for each disposal location with a more aesthetic design
struct DisposalLocationCard: View {
    var location: DisposalLocation

    var body: some View {
        HStack { // Use HStack to left-align text within the card
            Text(location.name)
                .font(.headline)
                .foregroundColor(Color(hex: "#154F39"))  // Use your dark green color
                .padding(.vertical, 10)
                .padding(.horizontal, 20)

            Spacer() // Adds space to push text to the left
        }
        .frame(maxWidth: .infinity)  // Make sure the frame takes full width
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)  // Adds padding around the card
    }
}

struct b1Disposal_Previews: PreviewProvider {
    static var previews: some View {
        b1Disposal(
            itemName: "Battery",
            displayText: "Hazardous Waste",
            nearbyLocations: []
        )
        .environmentObject(CartManager()) // Inject the CartManager for preview
    }
}
