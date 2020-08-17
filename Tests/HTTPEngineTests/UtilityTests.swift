import XCTest
import Foundation
@testable import HTTPEngine

class UtitlityTests: XCTestCase {
    func testTripQuestionsThrowsIfNil() {
        let x: Int? = nil
        do {
            _ = try x ??? Errors.Request.invalidURL
            XCTFail(#function)
        }
        catch let error{
            XCTAssertEqual(error.localizedDescription, Errors.Request.invalidURL.localizedDescription)
        }
    }
    
    func testTripQuestionsUnwraps() {
        let x: Int? = 1
        do {
            XCTAssertEqual(try x ??? Errors.Request.invalidURL, 1)
        }
        catch {
            XCTFail(#function)
        }
    }
    
    func testThrowingPublisherThrows() {
        ThrowingPublisher(forType: Int.self, throws: Errors.Request.invalidURL)
            .assertError(test: self) {
                XCTAssertEqual($0.localizedDescription, Errors.Request.invalidURL.localizedDescription)
        }
    }
    
    
    static var allTests = [
        ("??? operator throws when unwrapping a nil", testTripQuestionsThrowsIfNil),
        ("??? unwraps values", testTripQuestionsUnwraps),
        ("Test throwing publisher throws", testThrowingPublisherThrows)
        
    ]

}
