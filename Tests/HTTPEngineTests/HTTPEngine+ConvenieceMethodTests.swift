import XCTest
import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import HTTPEngine

final class HTTPEngineConvenienceMethodTests: XCTestCase {
    static var allTests = [
    ("make request and parse response decodes into type", testMakeRequestAndParseResponseDecodesIntoType),
    ("make request and parse response throws if Decode fails", testMakeRequestAndParseResponseThrowsIfDecodeFails),
    ("make request and parse response Encodes and Decodes into type", testMakeRequestAndParseResponseEncodesAndDecodesIntoType),
    ("get succeeds", testGetSucceeds),
    ("post succeeds", testPostSucceeds),
    ]
    
    func testMakeRequestAndParseResponseDecodesIntoType() {
        stub(condition: isHost("google.com") && isMethodGET()) { _ in
            HTTPStubsResponse(jsonObject: ["key":"value"], statusCode: 200, headers: nil)
        }

        HTTPEngine()
            .makeRequestAndParseResponse(TestResponseBody.self, method: .get, url: "https://google.com")
            .assertResult(test: self) {
                XCTAssertEqual($0.key, "value")
        }
        
    }
    
    func testMakeRequestAndParseResponseThrowsIfDecodeFails() {
        stub(condition: isHost("google.com") && isMethodGET()) { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
        }

        HTTPEngine()
            .makeRequestAndParseResponse(TestResponseBody.self, method: .get, url: "https://google.com")
            .assertError(test: self) {
                XCTAssertNotNil($0)
        }
        
    }

    func testMakeRequestAndParseResponseEncodesAndDecodesIntoType() {
        HTTPEngine()
            .makeRequestAndParseResponse(TestResponseBody.self, method: .get, url: "https://google.com", body: TestResponseBody(key: "something"))
            .assertResult(test: self) {
                XCTAssertEqual($0.key, "value")
        }
    }
    
    func testGetSucceeds() {
        stub(condition: isHost("google.com") && isMethodGET()) { _ in
            HTTPStubsResponse(jsonObject: ["key": "value"], statusCode: 200, headers: nil)
        }

        HTTPEngine()
            .get(TestResponseBody.self, url: "https://google.com")
            .assertResult(test: self) {
                XCTAssertEqual($0.key, "value")

        }
    }
    
    func testPostSucceeds() {
        stub(condition: isHost("google.com") && isMethodPOST()) { _ in
            HTTPStubsResponse(jsonObject: ["key": "value"], statusCode: 200, headers: nil)
        }

        HTTPEngine()
            .post(TestResponseBody.self, url: "https://google.com")
            .assertResult(test: self) {
                XCTAssertEqual($0.key, "value")
        }
    }
}
    
struct TestResponseBody: Codable {
    let key: String
}
