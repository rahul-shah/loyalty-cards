import XCTest
import SwiftUI
import ViewInspector
@testable import Loyalty_Cards

extension LoginView: Inspectable {}
extension StoredCardView: Inspectable {}
extension CardsListView: Inspectable {}

class ViewTests: XCTestCase {
    func testLoginViewStructure() throws {
        let view = LoginView()
        
        // Test navigation view presence
        XCTAssertNoThrow(try view.inspect().navigationView())
        
        // Test main VStack structure
        let vstack = try view.inspect().navigationView().vStack()
        
        // Test app icon
        XCTAssertNoThrow(try vstack.image(0))
        
        // Test title text
        let titleText = try vstack.text(1)
        XCTAssertEqual(try titleText.string(), "Loyalty Cards")
        
        // Test subtitle text
        let subtitleText = try vstack.text(2)
        XCTAssertEqual(try subtitleText.string(), "Store all your loyalty cards in one place")
        
        // Test Sign in with Apple button presence
        XCTAssertNoThrow(try vstack.find(viewWithId: "signInWithAppleButton"))
    }
    
    func testStoredCardViewStructure() throws {
        let context = PersistenceController(inMemory: true).container.viewContext
        let card = LoyaltyCard(context: context)
        card.name = "Test Card"
        card.logoName = "creditcard.fill"
        
        let view = StoredCardView(card: card)
        
        // Test main VStack structure
        let vstack = try view.inspect().vStack()
        
        // Test HStack containing card details
        let hstack = try vstack.hStack(0)
        
        // Test logo circle
        XCTAssertNoThrow(try hstack.circle(0))
        
        // Test card name
        let nameText = try hstack.text(1)
        XCTAssertEqual(try nameText.string(), "Test Card")
        
        // Test category icon
        XCTAssertNoThrow(try hstack.circle(2))
    }
    
    func testCardsListViewStructure() throws {
        let view = CardsListView()
        
        // Test navigation view presence
        XCTAssertNoThrow(try view.inspect().navigationView())
        
        // Test ZStack structure
        let zstack = try view.inspect().navigationView().zStack()
        
        // Test ScrollView presence
        XCTAssertNoThrow(try zstack.scrollView(0))
        
        // Test bottom navigation bar presence
        let bottomBar = try zstack.vStack(1)
        XCTAssertNoThrow(try bottomBar.hStack(1))
        
        // Test add button presence
        XCTAssertNoThrow(try bottomBar.hStack(1).button(1))
    }
    
    func testCardColorLogic() {
        let context = PersistenceController(inMemory: true).container.viewContext
        let card = LoyaltyCard(context: context)
        
        // Test Tesco color
        card.name = "Tesco Clubcard"
        var view = StoredCardView(card: card)
        XCTAssertEqual(view.brandColor, Color(hex: "00539F"))
        
        // Test M&S color
        card.name = "Marks & Spencer"
        view = StoredCardView(card: card)
        XCTAssertEqual(view.brandColor, Color(hex: "C4CDD5"))
        
        // Test default color
        card.name = "Unknown Card"
        view = StoredCardView(card: card)
        XCTAssertEqual(view.brandColor, Color(hex: "333333"))
    }
} 