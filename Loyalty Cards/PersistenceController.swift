import CoreData
import SwiftUI

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LoyaltyCard")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        if let storeURL = container.persistentStoreDescriptions.first?.url {
            let storeDirectory = storeURL.deletingLastPathComponent()
            do {
                try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Error loading Core Data: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func addCard(name: String, category: String, logoName: String, backgroundColor: Color, cardNumber: String, location: String) {
        let context = container.viewContext
        let card = LoyaltyCard(context: context)
        card.id = UUID()
        card.name = name
        card.category = category
        card.logoName = logoName
        card.backgroundColor = backgroundColor.description
        card.cardNumber = cardNumber
        card.location = location
        card.stamps = 0
        card.totalStamps = 10
        
        save()
    }
    
    func deleteCard(_ card: LoyaltyCard) {
        let context = container.viewContext
        context.delete(card)
        save()
    }
} 