import SwiftUI
import MapKit
import GoogleMaps
import CoreLocation


func fetchDirections(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (GMSPath?, [DirectionStep]) -> Void) {
    let originString = "\(origin.latitude),\(origin.longitude)"
    let destinationString = "\(destination.latitude),\(destination.longitude)"
    
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&key=AIzaSyDzFxK1cdjo6pJNdMWgfaezWhTA5p--2zs"
    
    guard let url = URL(string: urlString) else {
        DispatchQueue.main.async {
            completion(nil, [])
        }
        return
    }

    
    DispatchQueue.global(qos: .utility).async {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, [])
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let route = routes.first,
                   let overviewPolyline = route["overview_polyline"] as? [String: Any],
                   let points = overviewPolyline["points"] as? String,
                   let legs = route["legs"] as? [[String: Any]] {

                    var steps: [DirectionStep] = []
                    for leg in legs {
                        if let legSteps = leg["steps"] as? [[String: Any]] {
                            for step in legSteps {
                                if let htmlInstructions = step["html_instructions"] as? String,
                                   let distance = step["distance"] as? [String: Any],
                                   let distanceText = distance["text"] as? String {
                                    let cleanInstructions = htmlInstructions.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                    steps.append(DirectionStep(instruction: cleanInstructions, distance: distanceText))
                                }
                            }
                        }
                    }

                    let path = GMSPath(fromEncodedPath: points)

                    
                    DispatchQueue.main.async {
                        completion(path, steps)
                    }

                } else {
                    DispatchQueue.main.async {
                        completion(nil, [])
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, [])
                }
            }
        }.resume()
    }
}

struct GMap: View {
    var cartItems: [String]
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var chatController: ChatController
    @State private var directions: [DirectionStep] = []
    
    var body: some View {
        VStack {
            if let userLocation = locationManager.userLocation {
                ZStack {
                   
                    MapViewWrapper(cartItems: cartItems, userLocation: userLocation, directions: $directions)
                        .edgesIgnoringSafeArea(.all)
                        .environmentObject(locationManager)
                        .environmentObject(chatController)
                    
                    VStack {
                        Spacer()
                        Button(action: {
                          
                            locationManager.recenterMap()
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding()
                    }
                }
            } else {
                Text("Getting user location...")
            }
   
            if !directions.isEmpty {
                List(directions) { step in
                    HStack {
                        Image(systemName: "arrow.right")
                        VStack(alignment: .leading) {
                            Text(step.instruction)
                                .font(.body)
                                .foregroundColor(.primary)
                            Text(step.distance)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: 200)
            }
        }
    }
}

struct MapViewWrapper: UIViewRepresentable {
    var cartItems: [String]
    var userLocation: CLLocationCoordinate2D
    @Binding var directions: [DirectionStep]

    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var chatController: ChatController
    let mapView = GMSMapView()

    let blockedCategories = ["General Trash", "Household Waste", "Unrecyclable Waste"] // Define blocked categories

    func makeUIView(context: Context) -> GMSMapView {
    
        GMSServices.provideAPIKey("AIzaSyDzFxK1cdjo6pJNdMWgfaezWhTA5p--2zs")

        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.latitude, longitude: userLocation.longitude, zoom: 12.0)
        mapView.camera = camera

       
        let userMarker = GMSMarker()
        userMarker.position = userLocation
        userMarker.title = "Your Location"
        userMarker.map = mapView

        
        var disposalCategoryToItems: [String: [String]] = [:]
        let groupDispatchGroup = DispatchGroup()

        for item in cartItems {
            groupDispatchGroup.enter()
            chatController.getDisposalMethod(for: item) { disposalMethod, _ in
                if blockedCategories.contains(disposalMethod) {
                    print("\(item) is general waste, skipping location fetch.")
                } else {
                    disposalCategoryToItems[disposalMethod, default: []].append(item)
                }
                groupDispatchGroup.leave()
            }
        }

       
        groupDispatchGroup.notify(queue: .main) {
            mapView.clear()

            
            userMarker.map = mapView

         
            for (disposalMethod, items) in disposalCategoryToItems {
                fetchNearbyDisposalLocations(userLocation: userLocation, disposalCategory: disposalMethod) { locations in
                    DispatchQueue.main.async {
                        if let closestLocation = getClosestLocation(userLocation: userLocation, locations: locations) {
                            let itemNames = items.joined(separator: ", ")

                        
                            let marker = GMSMarker()
                            marker.position = closestLocation.coordinate
                            marker.title = closestLocation.name
                            marker.snippet = "Items: \(itemNames)"
                            marker.map = mapView

                            
                            fetchDirections(from: userLocation, to: closestLocation.coordinate) { path, steps in
                                if let path = path {
                                  
                                    let polyline = GMSPolyline(path: path)
                                    polyline.strokeWidth = 5.0
                                    polyline.strokeColor = .blue
                                    polyline.map = mapView
                                }

                                directions = steps
                            }
                        }
                    }
                }
            }
        }

        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
   
    }

    
    private func getClosestLocation(userLocation: CLLocationCoordinate2D, locations: [DisposalLocation]) -> DisposalLocation? {
        return locations.min(by: { location1, location2 in
            let distance1 = CLLocation(latitude: location1.coordinate.latitude, longitude: location1.coordinate.longitude)
                .distance(from: CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude))
            let distance2 = CLLocation(latitude: location2.coordinate.latitude, longitude: location2.coordinate.longitude)
                .distance(from: CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude))
            
            
            return distance1 < distance2
        })
    }
}


extension LocationManager {
    var mapView: GMSMapView? {
        get {
            return nil
        }
        set {
            
        }
    }

    func recenterMap() {
        if let location = userLocation, let mapView = mapView {
            let cameraUpdate = GMSCameraUpdate.setTarget(location)
            mapView.animate(with: cameraUpdate)
        }
    }
}


struct DirectionStep: Identifiable {
    let id = UUID()
    let instruction: String
    let distance: String
}
