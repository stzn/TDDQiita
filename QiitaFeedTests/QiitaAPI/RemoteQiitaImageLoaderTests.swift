//
//  QiitaImageLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
@testable import QiitaFeed

class RemoteQiitaImageLoaderTests: XCTestCase {
    func testFetchDataFetched() {
        let data = anyData
        expect(.success(data), responseResult: .success((data, anyHTTPURLResponse)))
    }

    func testFetchRequestError() {
        let error = anyHTTPClientError
        expect(.failure(error), responseResult: .failure(error))
    }

    func testCancelNoDataFetched() {
        let data = anyData
        let (loader, client) = makeTestTarget()

        let exp = expectation(description: "expect")
        let task = loader.load(url: anyURL) { _ in
            XCTFail("should not come here")
            exp.fulfill()
        }
        task.cancel()
        client.completeWith(result: .success((data, anyHTTPURLResponse)))

        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        switch result {
        case .timedOut:
            break
        default:
            XCTFail("timeout should occur")
        }
    }

    // MARK: Helpers
    typealias Assert = (RemoteQiitaImageLoader.Result, RemoteQiitaImageLoader.Result) -> Bool

    private func expect(_ expected: RemoteQiitaImageLoader.Result,
                        responseResult: HTTPClient.Result,
                        httpURLResponse: HTTPURLResponse = anyHTTPURLResponse,
                        file: StaticString = #file, line: UInt = #line) {
        let (loader, client) = makeTestTarget(file: file, line: line)
        let exp = expectation(description: "expect")
        loader.load(url: anyURL) { received in
            defer { exp.fulfill() }

            switch (received, expected) {
            case (.success(let lhs), .success(let rhs)):
                XCTAssertEqual(lhs, rhs, file: file, line: line)
            case (.failure(let lhs), .failure(let rhs)):
                XCTAssertEqual(lhs as! HTTPClientError, rhs as! HTTPClientError, file: file, line: line)
            default:
                XCTFail("\(expected) want but got \(received)")
            }
        }
        client.completeWith(result: responseResult)
        wait(for: [exp], timeout: 1.0)
    }

    private func makeTestTarget(file: StaticString = #file, line: UInt = #line)
        -> (RemoteQiitaImageLoader, HTTPClientSpy) {
            let client = HTTPClientSpy()
            let target = RemoteQiitaImageLoader(client: client)
            trackForMemoryLeaks(target, file: file, line: line)
            return (target, client)
    }
}
