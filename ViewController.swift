import UIKit
import CoreML
import Vision



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            self.imageView.image = image
            classifyImage(image)
        }
    }
    
    lazy var model: VNCoreMLModel = {
        do {
            return try VNCoreMLModel(for: SavedModel().model)
        } catch {
            fatalError("Failed to load model: \(error)")
        }
    }()
    
    lazy var request: VNCoreMLRequest = {
        return VNCoreMLRequest(model: model) { (request, error) in
            if let error = error {
                print("Error in classification request: \(error.localizedDescription)")
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                print("Unexpected result type from VNCoreMLRequest: \(String(describing: request.results))")
                return
            }
            
            if let topResult = results.first {
                DispatchQueue.main.async {
                    self.predictionLabel.text = "\(topResult.identifier) (\(topResult.confidence * 100)%)"
                }
            } else {
                print("No results found in classification")
            }
        }
    }()
    
    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Unable to create CIImage from UIImage")
            return
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([self.request])
            } catch {
                print("Failed to perform classification. Error: \(error.localizedDescription)")
            }
        }
    }
}
