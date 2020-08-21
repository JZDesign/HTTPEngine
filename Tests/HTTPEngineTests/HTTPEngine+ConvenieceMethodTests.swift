import XCTest
import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import HTTPEngine

final class HTTPEngineConvenienceMethodTests: XCTestCase {

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
    
    func testPatchSucceeds() {
        stub(condition: isHost("google.com") && isMethodPATCH()) { _ in
            HTTPStubsResponse(jsonObject: ["key": "value"], statusCode: 200, headers: nil)
        }

        HTTPEngine()
            .patch(TestResponseBody.self, url: "https://google.com", body: nil as TestResponseBody?)
            .assertResult(test: self) {
                XCTAssertEqual($0.key, "value")
        }
    }
    
    func testPutSucceeds() {
        stub(condition: isHost("google.com") && isMethodPUT()) { _ in
            HTTPStubsResponse(jsonObject: ["key": "value"], statusCode: 200, headers: nil)
        }

        HTTPEngine()
            .put(TestResponseBody.self, url: "https://google.com", body: nil as TestResponseBody?)
            .assertResult(test: self) {
                XCTAssertEqual($0.key, "value")
        }
    }
    
    func testDeleteSucceeds() {
        stub(condition: isHost("google.com") && isMethodDELETE()) { _ in
            HTTPStubsResponse(jsonObject: ["key": "value"], statusCode: 200, headers: nil)
        }

        HTTPEngine()
            .delete(TestResponseBody.self, url: "https://google.com", body: nil as TestResponseBody?)
            .assertResult(test: self) {
                XCTAssertEqual($0.key, "value")
        }
    }
}
    
struct TestResponseBody: Codable {
    let key: String
}
