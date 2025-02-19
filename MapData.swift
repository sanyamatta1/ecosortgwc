//
//  MapData.swift
//  EcoSort
//
//  Created by sanya matta on 8/23/24.
//

import Foundation



// Define the disposal locations dataset
let disposalLocations: [String: (latitude: Double, longitude: Double, type: String)] = [
    "Plastic Bottle": (latitude: 37.7749, longitude: -122.4194, type: "Recycling Center"),
    "Banana Peel": (latitude: 37.7849, longitude: -122.4094, type: "Compost Facility"),
    "Battery": (latitude: 37.7649, longitude: -122.4294, type: "Hazardous Waste")
]


 

//want to make it so that chatpgt also takes in items added into the cart, and categorizes it into the wastemanegemnt categories given by google maps, so i can show it
