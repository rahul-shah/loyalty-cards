import XCTest
@testable import Loyalty_Cards
import AuthenticationServices

class AuthenticationManagerTests: XCTestCase {
    var sut: AuthenticationManager!
    let userDefaults = UserDefaults.standard
    
    override func setUp() {
        super.setUp()
        // Clear any existing user defaults before each test
        userDefaults.removeObject(forKey: "isAuthenticated")
        userDefaults.removeObject(forKey: "appleUserIdentifier")
        userDefaults.removeObject(forKey: "userName")
        userDefaults.removeObject(forKey: "userEmail")
        
        sut = AuthenticationManager.shared
    }
    
    override func tearDown() {
        // Clean up after each test
        userDefaults.removeObject(forKey: "isAuthenticated")
        userDefaults.removeObject(forKey: "appleUserIdentifier")
        userDefaults.removeObject(forKey: "userName")
        userDefaults.removeObject(forKey: "userEmail")
        sut = nil
        super.tearDown()
    }
    
    func testInitialAuthenticationState() {
        XCTAssertFalse(sut.isAuthenticated, "Initial authentication state should be false")
    }
    
    func testAuthenticationStateChange() {
        // When
        sut.isAuthenticated = true
        
        // Then
        XCTAssertTrue(sut.isAuthenticated, "Authentication state should be true")
        XCTAssertTrue(userDefaults.bool(forKey: "isAuthenticated"), "UserDefaults should store authentication state")
    }
    
    func testPersistentAuthenticationState() {
        // Given
        userDefaults.set(true, forKey: "isAuthenticated")
        
        // When
        let newAuthManager = AuthenticationManager.shared
        
        // Then
        XCTAssertTrue(newAuthManager.isAuthenticated, "Authentication state should persist")
    }
} 