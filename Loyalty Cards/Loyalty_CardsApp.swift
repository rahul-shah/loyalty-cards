//
//  Loyalty_CardsApp.swift
//  Loyalty Cards
//
//  Created by Rahul Shah on 12/19/24.
//

import SwiftUI

@main
struct Loyalty_CardsApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
