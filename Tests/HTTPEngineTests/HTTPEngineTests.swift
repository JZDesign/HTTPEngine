import XCTest
import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import HTTPEngine

final class HTTPEngineTests: XCTestCase {
    
    // MARK: - Build Request
    
    func testBuildRequestContainsAcceptEncodingByDefault() {
        HTTPMethod.allCases.forEach {
            let request = HTTPEngine().buildRequest(method: $0, url: URL(string: "www.google.com")!)
            XCTAssertEqual(request.allHTTPHeaderFields?["Accept-Encoding"], "gzip;q=1.0,compress;q=0.5")
        }
    }
    
    func testBuildRequestsOverridesAcceptEncodingHeader() {
        let request = HTTPEngine()
            .buildRequest(
                method: .get,
                url: URL(string: "www.google.com")!,
                header: ["Accept-Encoding": "something"])
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept-Encoding"], "something")
    }

    func testPostPatchPutContainDefaultContentTypeHeader() {
        let methods: [HTTPMethod] = [.post, .patch, .put]
        methods.forEach {
            let request = HTTPEngine().buildRequest(method: $0, url: URL(string: "www.google.com")!)
            XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json")
        }
    }
    
    func testNonPostPatchPutMethodsDoNotContainDefaultContentTypeHeader() {
        let methods: [HTTPMethod] = [.get, .delete]
        methods.forEach {
            let request = HTTPEngine().buildRequest(method: $0, url: URL(string: "www.google.com")!)
            XCTAssertNil(request.allHTTPHeaderFields?["Content-Type"])
        }
    }
    
    
    func testBuildRequestOverridesContentTypeHeader() {
        let methods: [HTTPMethod] = HTTPMethod.allCases
        methods.forEach {
            let request = HTTPEngine()
                .buildRequest(
                    method: $0,
                    url: URL(string: "www.google.com")!,
                    header: ["Content-Type": "something"]
            )
            XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "something")
        }
    }
    
    func testBuildRequestAppliesBodyToRequest() {
        let request = HTTPEngine().buildRequest(method: .get, url: URL(string: "www.google.com")!, body: "".data(using: .utf8)!)
        XCTAssertNotNil(request.httpBody)
    }
    
    func testBuildRequestAppliesMethodToRequest() {
        let request = HTTPEngine().buildRequest(method: .get, url: URL(string: "www.google.com")!)
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    // MARK: - Make Request
    
    func testMakeRequestFailsWithUnexpectedResponseCode() {
        stub(condition: isHost("google.com") && isMethodGET()) { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
        }

        HTTPEngine()
            .makeRequest(method: .get, url: "https://google.com", validator: { $0 == 202 })
            .assertError(test: self) {
                switch $0 {
                case Errors.Response.unexpectedStatusCode(let response):
                    XCTAssertEqual(response.statusCode, 200)
                default: XCTFail(#function)
                }
        }
    }
    
    func testMakeRequestSucceedsIn200RangeByDefault() {
        for statusCode in (200...299) {
            stub(condition: isHost("google.com") && isMethodGET()) { _ in
                HTTPStubsResponse(jsonObject: ["key":"value"], statusCode: Int32(statusCode), headers: nil)
            }

            HTTPEngine()
                .makeRequest(method: .get, url: "https://google.com")
                .assertResult(test: self) {
                    XCTAssertEqual(
                        ["key": "value"],
                        try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: String]
                    )
            }
        }
    }
    
    
    func testMakeRequestFailsOutsideOf200RangeByDefault() {
        stub(condition: isHost("google.com") && isMethodGET()) { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 300, headers: nil)
        }

        HTTPEngine()
            .makeRequest(method: .get, url: "https://google.com")
            .assertError(test: self) {
                XCTAssertEqual($0.localizedDescription, Errors.Response.redirect(300).localizedDescription)
        }
        
        stub(condition: isHost("google.com") && isMethodGET()) { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 199, headers: nil)
        }

        HTTPEngine()
            .makeRequest(method: .get, url: "https://google.com")
            .assertError(test: self) {
                XCTAssertEqual($0.localizedDescription, Errors.Response.errorWith(statusCode: 199)?.localizedDescription)
        }
    }

    
    static var allTests = [
        ("Default Accept Encoding Header", testBuildRequestContainsAcceptEncodingByDefault),
        ("Override Accept Encoding Header", testBuildRequestsOverridesAcceptEncodingHeader),
        ("Put Patch Post contain default Content Type header", testPostPatchPutContainDefaultContentTypeHeader),
        ("Non Put Patch Post do not contain content type header", testNonPostPatchPutMethodsDoNotContainDefaultContentTypeHeader),
        ("Build request overrides content type header", testBuildRequestOverridesContentTypeHeader),
        ("Build Request applies body to request", testBuildRequestAppliesBodyToRequest),
        ("Build Request applies Method to request", testBuildRequestAppliesMethodToRequest),
        ("Make Request Fails with invalid status code",
         testMakeRequestFailsWithUnexpectedResponseCode),
        ("Make Request Succeeds in 200 range by default", testMakeRequestSucceedsIn200RangeByDefault),
        ("Make request fails outside of 200 range by default", testMakeRequestFailsOutsideOf200RangeByDefault)
    ]
}
