//
//  ContentView.swift
//  Loyalty Cards
//
//  Created by Rahul Shah on 12/19/24.
//

import SwiftUI

struct CardMenu: View {
    
    var cardItemsArray:[CardItem] = []
    
    var body: some View {
        NavigationStack {
            List {
                Text("Hello, world!")
                Text("Hello, world!")
                Text("Hello, world!")
            }
            .navigationTitle("Cards")
        }
    }
}

#Preview {
    CardMenu()
}
