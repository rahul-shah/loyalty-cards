//
//  Loyalty_CardsApp.swift
//  Loyalty Cards
//
//  Created by Rahul Shah on 12/19/24.
//

import SwiftUI

@main
struct Loyalty_CardsApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            CardsListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.dark)
            #else
            CardsListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(minWidth: 800, minHeight: 600)
                .preferredColorScheme(.dark)
            #endif
        }
    }
}
