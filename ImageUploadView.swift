import SwiftUI
import CoreML
import UIKit
import CoreVideo

extension UIImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32BGRA,
                                         attributes as CFDictionary,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
       
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        return buffer
    }

   
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

struct ImageUploadView: View {
    @State private var selectedImage: UIImage?
    @State private var classificationLabel: String = ""
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                    .padding()
            } else {
                Text("No Image Selected")
                    .font(.headline)
                    .padding()
            }

            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("Upload Image")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding()

            if !classificationLabel.isEmpty {
                Text("Classification: \(classificationLabel)")
                    .font(.headline)
                    .padding()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            CustomImagePicker(selectedImage: $selectedImage, onImagePicked: classifyImageDirectly)
        }
        .navigationTitle("Image Upload")
    }

    func classifyImageDirectly(_ image: UIImage) {
        print("Classifying image directly with Core ML...")

       
        if let resizedImage = image.resized(to: CGSize(width: 299, height: 299)),
           let pixelBuffer = resizedImage.toPixelBuffer() {
            // Use MyModel directly for classification
            do {
                let model = MyModel()
                let prediction = try model.prediction(image: pixelBuffer)
                classificationLabel = prediction.target
                print("Direct classification result: \(classificationLabel)")
            } catch {
                classificationLabel = "Classification failed: \(error.localizedDescription)"
                print("Classification failed with error: \(error)")
            }
        } else {
            classificationLabel = "Failed to process image."
            print("Error: Image resizing or pixel buffer conversion failed.")
        }
    }
}

struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
