import XCTest
import Foundation
@testable import HTTPEngine

final class HTTPEngineTests: XCTestCase {
    
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

    
    static var allTests = [
        ("Default Accept Encoding Header", testBuildRequestContainsAcceptEncodingByDefault),
        ("Override Accept Encoding Header", testBuildRequestsOverridesAcceptEncodingHeader),
        ("Put Patch Post contain default Content Type header", testPostPatchPutContainDefaultContentTypeHeader),
        ("Non Put Patch Post do not contain content type header", testNonPostPatchPutMethodsDoNotContainDefaultContentTypeHeader),
        ("Build request overrides content type header", testBuildRequestOverridesContentTypeHeader),
        ("Build Request applies body to request", testBuildRequestAppliesBodyToRequest),
        ("Build Request applies Method to request", testBuildRequestAppliesMethodToRequest)
    ]
}
