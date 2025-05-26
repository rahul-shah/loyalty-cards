import XCTest
@testable import Loyalty_Cards
import CoreData

class CardManagementTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        persistenceController = nil
        context = nil
        super.tearDown()
    }
    
    func testCreateCard() {
        // Given
        let card = LoyaltyCard(context: context)
        card.name = "Test Card"
        card.cardNumber = "1234567890"
        card.logoName = "creditcard.fill"
        
        // When
        try? context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<LoyaltyCard> = LoyaltyCard.fetchRequest()
        let results = try? context.fetch(fetchRequest)
        XCTAssertEqual(results?.count, 1, "Should have one card in the database")
        XCTAssertEqual(results?.first?.name, "Test Card", "Card name should match")
        XCTAssertEqual(results?.first?.cardNumber, "1234567890", "Card number should match")
    }
    
    func testUpdateCard() {
        // Given
        let card = LoyaltyCard(context: context)
        card.name = "Test Card"
        card.cardNumber = "1234567890"
        try? context.save()
        
        // When
        card.name = "Updated Card"
        try? context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<LoyaltyCard> = LoyaltyCard.fetchRequest()
        let results = try? context.fetch(fetchRequest)
        XCTAssertEqual(results?.first?.name, "Updated Card", "Card name should be updated")
    }
    
    func testDeleteCard() {
        // Given
        let card = LoyaltyCard(context: context)
        card.name = "Test Card"
        try? context.save()
        
        // When
        context.delete(card)
        try? context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<LoyaltyCard> = LoyaltyCard.fetchRequest()
        let results = try? context.fetch(fetchRequest)
        XCTAssertEqual(results?.count, 0, "Database should be empty after deletion")
    }
    
    func testFetchCards() {
        // Given
        let cardNames = ["Card 1", "Card 2", "Card 3"]
        
        for name in cardNames {
            let card = LoyaltyCard(context: context)
            card.name = name
            try? context.save()
        }
        
        // When
        let fetchRequest: NSFetchRequest<LoyaltyCard> = LoyaltyCard.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \LoyaltyCard.name, ascending: true)]
        let results = try? context.fetch(fetchRequest)
        
        // Then
        XCTAssertEqual(results?.count, 3, "Should have three cards in the database")
        XCTAssertEqual(results?.map { $0.name }, cardNames.sorted(), "Cards should be sorted by name")
    }
} 