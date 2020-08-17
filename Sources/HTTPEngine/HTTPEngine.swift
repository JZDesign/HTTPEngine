import Foundation
import Combine

public typealias Header = [String: String]
public typealias ValidResponse = Bool
public typealias ResponseValidationClosure = (Int) -> ValidResponse

public struct HTTPEngine {
    public init() {}

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
    
    func validateResponse(_ response: URLResponse?, validator: ResponseValidationClosure? = nil) throws {
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
