import Foundation

public typealias Header = [String: String]

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
    
}
