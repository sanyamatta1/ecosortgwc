import Foundation
import SwiftUI
import MapKit
import GoogleMaps
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location.coordinate
            locationManager.stopUpdatingLocation() 
        }
    }
}

struct DisposalLocation {
    let name: String
    let coordinate: CLLocationCoordinate2D
}

func fetchNearbyDisposalLocations(userLocation: CLLocationCoordinate2D, disposalCategory: String, completion: @escaping ([DisposalLocation]) -> Void) {
    let latitude = userLocation.latitude
    let longitude = userLocation.longitude
    let radius = 5000

    let searchTerm = mapDisposalMethodToSearchTerm(disposalCategory)

    let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&keyword=\(searchTerm)&key=AIzaSyDzFxK1cdjo6pJNdMWgfaezWhTA5p--2zs"

    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion([])
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching nearby locations: \(error)")
            completion([])
            return
        }

        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                var locations: [DisposalLocation] = []

                if let results = json?["results"] as? [[String: Any]] {
                    for result in results {
                        if let name = result["name"] as? String,
                           let geometry = result["geometry"] as? [String: Any],
                           let location = geometry["location"] as? [String: Any],
                           let lat = location["lat"] as? Double,
                           let lng = location["lng"] as? Double {
                            locations.append(DisposalLocation(name: name, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)))
                        }
                    }
                }
                
                completion(locations)
            } catch {
                print("Error parsing response: \(error)")
                completion([])
            }
        }
    }.resume()
}
func mapDisposalMethodToSearchTerm(_ disposalMethod: String) -> String {
    switch disposalMethod {
    case "Recyclable":
        return "recycling center"
    case "Compostable":
        return "compost facility"
    case "Hazardous Waste":
        return "hazardous waste disposal"
    case "Donation":
        return "donation center"
    case "Scrapyard":
        return "scrapyard"
    case "Landfill":
        return "landfill"
    default:
        return "waste disposal"
    }
}
