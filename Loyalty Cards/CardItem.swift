//
//  MenuItem.swift
//  Loyalty Cards
//
//  Created by Rahul Shah on 12/20/24.
//

import Foundation
import SwiftUI

struct CardItem: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let logoName: String
    let backgroundColor: Color
    var stamps: Int
    let totalStamps: Int
    
    static let sampleCards = [
        CardItem(name: "Travel Compass", location: "New York, United States", logoName: "airplane.circle.fill", backgroundColor: .blue, stamps: 0, totalStamps: 0),
        CardItem(name: "Star Coffee Cafe", location: "New York, United States", logoName: "cup.and.saucer.fill", backgroundColor: .yellow, stamps: 0, totalStamps: 0),
        CardItem(name: "EXO Travel", location: "New York, United States", logoName: "airplane.departure", backgroundColor: .green, stamps: 0, totalStamps: 0),
        CardItem(name: "Chipotle Mexican Grill", location: "New York, United States", logoName: "fork.knife.circle.fill", backgroundColor: .orange, stamps: 8, totalStamps: 10)
    ]
}
