import Foundation
import Combine

public extension URLRequest {
    func dataTaskPublisher() -> URLSession.DataTaskPublisher {
        return URLSession.shared.dataTaskPublisher(for: self)
    }
}

public func ThrowingPublisher<T>(forType type: T.Type, throws error: Error) -> AnyPublisher<T, Error> {
    Result<T?, Error> { nil }
        .publisher
        .eraseToAnyPublisher()
        .tryMap {
            guard let value = $0 else {
                throw error
            }
            return value
        }.eraseToAnyPublisher()
}

infix operator ??? : TernaryPrecedence
public func ???<T>(_ left: Optional<T>, right: Error) throws -> T {
    guard let value = left else { throw right }
    return value
}
