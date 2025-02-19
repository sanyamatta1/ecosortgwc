import SwiftUI
import PhotosUI
import CoreML
import Vision
import CoreLocation



struct b1Page: View {
    @State private var userInput: String = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var itemName: String = ""
    @State private var navigateToDisposal: Bool = false
    @State private var nearbyLocations: [DisposalLocation] = []
    @State private var showingAlert = false
    @State private var alertMessage: String = ""

    @EnvironmentObject var chatController: ChatController
    @EnvironmentObject var locationManager: LocationManager

    let blockedCategories = ["General Trash", "Household Waste", "Unrecyclable Waste"]

    var body: some View {
        NavigationView {
            VStack {
              
                VStack(spacing: 10) {
                    Text("Disposal Guide")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .padding(.top, 30)
                    
                    Text("Classify items and find disposal method")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 30)

                VStack(spacing: 20) {
                    HStack {
                      
                        Button(action: {
                            requestPhotoLibraryAccess()
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "#154F39"))
                                .padding(.leading, 10)
                        }

                    
                        TextField("Enter item name...", text: $userInput)
                            .padding(12)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                            .padding(.leading, 5)

                     
                        Button(action: {
                            processInput(input: userInput)
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "#154F39"))
                                .padding(.trailing, 10)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal, 30)

            
                    Text("Upload an image or type the name of the item")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                }

                Spacer()

               
                
                
              
                NavigationLink(
                    destination: b1Disposal(
                        itemName: itemName,
                        displayText: chatController.disposalMethod ?? "Loading...",
                        nearbyLocations: nearbyLocations
                    ),
                    isActive: $navigateToDisposal
                ) {
                    EmptyView()
                }
            }
            .padding(.bottom, 20)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $inputImage, onImagePicked: classifyImage)
            }
        }
    }

    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self.showingImagePicker = true
                case .denied, .restricted, .notDetermined:
                    self.showAlert(message: "Photo Library access denied or restricted")
                @unknown default:
                    fatalError("Unknown photo library authorization status")
                }
            }
        }
    }

    func classifyImage(_ image: UIImage?) {
        guard let image = image else {
            showAlert(message: "No image selected")
            return
        }

        guard let resizedImage = resizeImage(image, targetSize: CGSize(width: 360, height: 360)),
              let ciImage = CIImage(image: resizedImage) else {
            showAlert(message: "Failed to process image for classification")
            return
        }

        guard let model = try? VNCoreMLModel(for: SavedModel().model) else {
            showAlert(message: "Failed to load Model")
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                showAlert(message: "Classification failed: \(error.localizedDescription)")
                return
            }

            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                showAlert(message: "Unexpected classification results")
                return
            }

            DispatchQueue.main.async {
                print("Original Classifier result: \(topResult.identifier)")

                let cleanedResult = topResult.identifier.replacingOccurrences(of: "(?i)small\\s*", with: "", options: .regularExpression)

                print("Cleaned Classifier result: \(cleanedResult)")

                self.userInput = cleanedResult.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
        do {
            try handler.perform([request])
        } catch {
            showAlert(message: "Failed to perform classification: \(error.localizedDescription)")
        }
    }



    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func processInput(input: String) {
        itemName = input
        chatController.getDisposalMethod(for: input) { disposalMethod, disposalCategory in
            DispatchQueue.main.async {
                chatController.disposalMethod = disposalMethod
                if blockedCategories.contains(disposalMethod ?? "") {
                    nearbyLocations = []
                } else if let userLocation = locationManager.userLocation {
                    fetchNearbyDisposalLocations(userLocation: userLocation, disposalCategory: disposalMethod ?? "") { locations in
                        DispatchQueue.main.async {
                            nearbyLocations = locations
                            navigateToDisposal = true
                        }
                    }
                } else {
                    showAlert(message: "Unable to determine location")
                }
            }
        }
    }

   
    func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }

 
}

struct b1Page_Previews: PreviewProvider {
    static var previews: some View {
        b1Page()
            .environmentObject(ChatController())
            .environmentObject(LocationManager())
    }
}
