import Foundation
import CoreLocation

// No need to redeclare DisposalLocation or fetchNearbyDisposalLocations

// In DisposalHelper.swift, just use the fetchNearbyDisposalLocations function defined in LocationManager.swift
// For example:

func someFunctionToUseNearbyLocations(userLocation: CLLocationCoordinate2D, disposalCategory: String) {
    // Use the function from LocationManager.swift to fetch nearby disposal locations
    fetchNearbyDisposalLocations(userLocation: userLocation, disposalCategory: disposalCategory) { locations in
        // Process the locations here
        for location in locations {
            print("Found disposal location: \(location.name)")
        }
    }
}
