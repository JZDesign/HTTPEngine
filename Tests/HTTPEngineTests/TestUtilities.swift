import XCTest
import Combine

private var cancelables: [AnyCancellable] = []

extension AnyPublisher {
    func noFailureOnMain() -> AnyPublisher<Output, Never> {
        assertNoFailure()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    @discardableResult
    func assertResult(
        _ function: String = #function,
        test: XCTestCase,
        _ assertions: @escaping (Output) -> Void = { _ in }
    ) -> AnyPublisher<Output, Failure> {

        let expectation = test.expectation(description: function)

        self
            .noFailureOnMain()
            .sink { value in
                assertions(value)
                expectation.fulfill()
        }
        .store(in: &cancelables)

        test.wait(for: [expectation], timeout: 1)
        return self
    }

    @discardableResult
    func assertNoError(
        _ function: String = #function,
        test: XCTestCase
    ) -> AnyPublisher<Output, Failure> {
        assertResult(function, test: test) { _ in }
    }

    @discardableResult
    func assertError(
        _ function: String = #function,
        test: XCTestCase,
        _ assertions: @escaping (Failure) -> Void
    ) -> AnyPublisher<Output, Failure> {

        let expectation = test.expectation(description: function)

        self
            .receive(on: DispatchQueue.main)
            .tryCatch { error -> Empty<Output, Error> in
                assertions(error)
                expectation.fulfill()
                return Empty(completeImmediately: true)
        }
        .assertNoFailure()
        .sink { _ in XCTFail(function) }
        .store(in: &cancelables)

        test.wait(for: [expectation], timeout: 1)
        return self
    }
}
