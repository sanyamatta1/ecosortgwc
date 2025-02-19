import SwiftUI
import GoogleMaps
import Firebase

@main
struct EcoSortApp: App {
    @StateObject private var cartManager = CartManager()
    @StateObject private var chatController = ChatController()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var disposalDataModel = DisposalDataModel()

    init() {
        GMSServices.provideAPIKey("AIzaSyDzFxK1cdjo6pJNdMWgfaezWhTA5p--2zs")
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            // First check if user is signed in, otherwise show WelcomeView
            if authViewModel.isSignedIn {
                ContentView()
                    .environmentObject(cartManager)
                    .environmentObject(chatController)
                    .environmentObject(locationManager)
                    .environmentObject(authViewModel)
                    .environmentObject(DisposalDataModel())
            } else {
                // Show the WelcomeView first if not signed in
                WelcomeView()
                    .environmentObject(authViewModel)
                    .environmentObject(cartManager)
                    .environmentObject(chatController)
                    .environmentObject(locationManager)
                    .environmentObject(DisposalDataModel())
            }
        }
    }
}
