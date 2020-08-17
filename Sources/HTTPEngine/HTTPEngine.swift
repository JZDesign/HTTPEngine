import Foundation
import Combine

public typealias Header = [String: String]
public typealias ValidResponse = Bool
public typealias ResponseValidationClosure = (Int) -> ValidResponse

public struct HTTPEngine {
    public init() {}


    /// Creates a URLRequest Object
    /// - Parameters:
    ///   - method: HTTPMethod - `.get, .put. post` etc.,
    ///   - url: A URL Object
    ///   - body: Data?: The body data to send with a request
    ///   - header: A dictionary of HTTP Request Headers - `["Content-Type": "text", "Some Key": "Some Value"]`
    /// - Returns: A fully constructed URLRequest
    ///
    ///    -- Headers
    ///
    ///    By default all requests have the `["Accept-Encoding": "gzip;q=1.0,compress;q=0.5"]` header included.
    ///
    ///    All `.post, .put, & .patch` requests also contain `["Content-Type": "application/json"]` by default.
    ///
    ///    These values can be overridden by including those headers as arguments when calling this function
    ///
    public func buildRequest(
        method: HTTPMethod,
        url: URL,
        body: Data? = nil,
        header: Header? = nil
    ) -> URLRequest {

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        request.httpBody = body
        request.allHTTPHeaderFields = header

        if request.allHTTPHeaderFields?["Content-Type"] == nil {
            if [HTTPMethod.post, HTTPMethod.put, HTTPMethod.patch].contains(method) {
                request.allHTTPHeaderFields?["Content-Type"] = "application/json"
            }
        }

        if request.allHTTPHeaderFields?["Accept-Encoding"] == nil {
            request.allHTTPHeaderFields?["Accept-Encoding"] = "gzip;q=1.0,compress;q=0.5"
        }

        return request
    }


    /// Makes a request via HTTP
    /// - Parameters:
    ///   - method: HTTPMethod - `.get, .put. post` etc.,
    ///   - urlString: URL domain + path as a string: `"abc.com/some/path"`
    ///   - body: Data?: The body data to send with a request
    ///   - header: A dictionary of HTTP Request Headers - `["Content-Type": "text", "Some Key": "Some Value"]`
    ///   - validator: `(Int) -> Bool` - A function to validate the response code of the request. By default, makeRequest() will fail if the status code does not fall within the 200 - 299 range. To override this, pass in a function that compares the status code and returns a boolean. True == success, False == failure. Upon failure an error will be thrown that contains the HTTPURLResponse for inspection.
    ///
    /// - Returns: AnyPubliser<Data, Error>
    ///
    ///    -- Headers
    ///
    ///    By default all requests have the `["Accept-Encoding": "gzip;q=1.0,compress;q=0.5"]` header included.
    ///
    ///    All `.post, .put, & .patch` requests also contain `["Content-Type": "application/json"]` by default.
    ///
    ///    These values can be overridden by including those headers as arguments when calling this function
    ///
    ///    -- Validation
    ///
    ///    By default the validation checks for a 200-299 status code and fails if the code is out of bounds
    ///    ```swift
    ///    // example validator
    ///    validator: { $0 == 202 }
    ///    ```
    public func makeRequest(
        method: HTTPMethod,
        url urlString: String,
        body: Data? = nil,
        header: Header? = nil,
        validator: ResponseValidationClosure? = nil
    ) -> AnyPublisher<Data, Error> {

        guard let url = URL(string: urlString) else {
            return ThrowingPublisher(forType: Data.self, throws: Errors.Request.invalidURL)
        }

        return buildRequest(method: method, url: url, body: body, header: header)
            .dataTaskPublisher()
            .eraseToAnyPublisher()
            .tryMap { value -> Data in
                try self.validateResponse(value.response, validator: validator)
                return value.data
            }
        .eraseToAnyPublisher()
    }


    private func validateResponse(_ response: URLResponse?, validator: ResponseValidationClosure? = nil) throws {
        let response = try response as? HTTPURLResponse ??? Errors.Response.couldNotRetrieveStatusCode

        guard let validator = validator else {
            if let error = Errors.Response.errorWith(statusCode: response.statusCode) {
                throw error
            }
            return
        }

        guard validator(response.statusCode) else {
            throw Errors.Response.unexpectedStatusCode(response)
        }
    }
    
}
