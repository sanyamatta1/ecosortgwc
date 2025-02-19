import SwiftUI
import PhotosUI
import CoreML
import Vision
import UIKit

struct Cart: View {
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var chatController: ChatController
    @State private var itemInput: String = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var classifiedText: String?
    @State private var navigateToMap = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    let generalHouseholdWaste: [String] = ["General Trash", "Household Waste", "Unrecyclable Waste"]

    var body: some View {
        NavigationView {
            VStack {
               
                Text("Your Disposal Cart")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)

                Divider()
                    .padding(.horizontal)

         
                List {
                    ForEach(cartManager.cartItems) { cartItem in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(cartItem.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(cartItem.disposalCategory)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()

                       
                            Button(action: {
                                cartManager.removeItem(cartItem)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.bottom)

                Spacer()

             
                HStack {
                    
                    Button(action: {
                        requestPhotoLibraryAccess()
                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "#154F39"))
                            .padding(.leading, 10)
                    }

                  
                    TextField("Enter item name...", text: $itemInput)
                        .padding(10)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(15)
                        .padding(.horizontal)

                  
                    Button(action: {
                        addItemToCart(itemInput)
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "#154F39"))
                            .padding(.trailing, 10)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .padding(.horizontal)

                
                Text("Upload an image or type the name of the item")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)

                Button(action: {
                    if !cartManager.cartItems.isEmpty {
                        navigateToMap = true
                    } else {
                        print("Cart is empty, cannot navigate.")
                    }
                }) {
                    Text("Finalize Disposal & Get Directions")
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#DACFBB"))
                        .cornerRadius(15)
                }
                .padding()
                .disabled(cartManager.cartItems.isEmpty)

               
                NavigationLink(
                    destination: GMap(cartItems: cartManager.cartItems.map { $0.name }),
                    isActive: $navigateToMap
                ) {
                    EmptyView()
                }
            }
            .padding(.bottom, 10)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Disposal Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $inputImage, onImagePicked: classifyImage)
            }
        
        }
    }


    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self.showingImagePicker = true
                case .denied, .restricted, .notDetermined:
                    print("Photo Library access denied or restricted")
                @unknown default:
                    fatalError("Unknown photo library authorization status")
                }
            }
        }
    }


    private func classifyImage(_ image: UIImage) {
        print("Starting classification...")

        guard let cgImage = image.cgImage else {
            print("Unable to get cgImage from image")
            return
        }

        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!

        let ciImage = CIImage(cgImage: cgImage)

        do {
            let model = try VNCoreMLModel(for: SavedModel().model)
            print("Model loaded successfully.")

            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let error = error {
                    print("Error during classification request: \(error.localizedDescription)")
                    return
                }

                guard let results = request.results as? [VNClassificationObservation], !results.isEmpty else {
                    print("No classification results.")
                    return
                }

                if let topResult = results.first {
                    DispatchQueue.main.async {
                        print("Top classification result: \(topResult.identifier)")

                 
                        let cleanedResult = topResult.identifier.replacingOccurrences(of: "(?i)small\\s*", with: "", options: .regularExpression)
                        print("Cleaned classification result: \(cleanedResult)")

                        self.addItemToCart(cleanedResult)
                    }
                }
            }

            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                    print("Classification request performed successfully.")
                } catch {
                    print("Error performing classification: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.alertMessage = "Error processing image: \(error.localizedDescription)"
                        self.showingAlert = true
                    }
                }
            }
        } catch {
            print("Error loading model: \(error.localizedDescription)")
            return
        }
    }

    
    private func addItemToCart(_ item: String) {
      
        let cleanedItem = item.replacingOccurrences(of: "(?i)small\\s*", with: "", options: .regularExpression)

        chatController.getDisposalMethod(for: cleanedItem) { disposalMethod, disposalCategory in
            DispatchQueue.main.async {
                if generalHouseholdWaste.contains(disposalMethod) {
                    alertMessage = "\(cleanedItem) is general household waste and should be put in regular trash."
                    showingAlert = true
                } else if disposalMethod == "No disposal method found" {
                    alertMessage = "\(cleanedItem) doesn't have a specific disposal location."
                    showingAlert = true
                } else {
                    let cartItem = CartItem(name: cleanedItem, disposalCategory: disposalMethod)
                    cartManager.addItem(cartItem)
                    alertMessage = "\(cleanedItem) added to the cart!"
                    showingAlert = true
                }
                itemInput = ""
            }
        }
    }

}





struct Cart_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Cart()
                .environmentObject(CartManager())
                .environmentObject(ChatController())
        }
    }
}
