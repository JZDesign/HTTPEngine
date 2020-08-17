import Foundation
import Combine

public extension HTTPEngine {
    
    /// Makes a request via HTTP
    /// - Parameters:
    ///   - decodableResponse: Decodable - An object that represents the response body
    ///   - method: HTTPMethod - `.get, .put. post` etc.,
    ///   - urlString: URL domain + path as a string: `"abc.com/some/path"`
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
    public func makeRequestAndParseResponse<Response: Decodable>(
        _ decodableResponse: Response.Type,
        method: HTTPMethod,
        url: String,
        header: Header? = nil,
        validator: ResponseValidationClosure? = nil
    ) -> AnyPublisher<Response, Error> {
        makeRequestAndParseResponse(decodableResponse, method: method, url: url, body: nil as Data?, header: header, validator: validator)
    }


    /// Makes a request via HTTP
    /// - Parameters:
    ///   - decodableResponse: Decodable - An object that represents the response body
    ///   - method: HTTPMethod - `.get, .put. post` etc.,
    ///   - urlString: URL domain + path as a string: `"abc.com/some/path"`
    ///   - body: Encodable?: The encodable object that represents body data to send with a request
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
    public func makeRequestAndParseResponse<Body: Encodable, Response: Decodable>(
        _ decodableResponse: Response.Type,
        method: HTTPMethod,
        url: String,
        body: Body?,
        header: Header? = nil,
        validator: ResponseValidationClosure? = nil
    ) -> AnyPublisher<Response, Error> {
        Just(body)
            .tryMap { $0 != nil ? try JSONEncoder().encode($0) : nil }
            .flatMap { self.makeRequest(method: method, url: url, body: $0, header: header, validator: validator) }
            .decode(type: decodableResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
