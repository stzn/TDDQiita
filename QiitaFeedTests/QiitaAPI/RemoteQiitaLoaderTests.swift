//
//  QiitaLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/14.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
@testable import QiitaFeed

class RemoteQiitaLoaderTests: XCTestCase {
    func testFetchItemsFetched() {
        let item = anyQiitaItem
        expect([item], responseResult: .success((encode([item]), anyHTTPURLResponse)))
    }

    func testFetchEmptyNoItemFetched() {
        expect([], responseResult: .success((encode([]), anyHTTPURLResponse)))
    }

    func testFetchLoadError() {
        expectError(.connectivity,
                    responseResult: .failure(HTTPClientError.noData))
    }

    func testFetchDecodeError() {
        expectError(.invalidData,
                    responseResult: .success((anyData, anyHTTPURLResponse)))
    }

    // MARK: Helpers
    typealias Assert = (RemoteQiitaLoader.Result, RemoteQiitaLoader.Result) -> Bool

    private func expect(_ expected: [QiitaItem],
                        responseResult: HTTPClient.Result,
                        file: StaticString = #file, line: UInt = #line) {
        let (loader, client) = makeTestTarget(file: file, line: line)
        let exp = expectation(description: "expect")
        loader.load { received in
            defer { exp.fulfill() }

            switch received {
            case .success(let items):
                XCTAssertEqual(items, expected, file: file, line: line)
            case .failure:
                XCTFail("\(expected) want but got \(received)")
            }
        }
        client.completeWith(result: responseResult)
        wait(for: [exp], timeout: 1.0)
    }

    private func expectError(_ expected: RemoteQiitaLoader.Error,
                        responseResult: HTTPClient.Result,
                        file: StaticString = #file, line: UInt = #line) {
        let (loader, client) = makeTestTarget(file: file, line: line)
        let exp = expectation(description: "expect error")
        loader.load { received in
            defer { exp.fulfill() }

            if case .failure(let error) = received {
                XCTAssertEqual(error as? RemoteQiitaLoader.Error, expected)
            } else {
                XCTFail("failure want but got \(received)")
            }
        }
        client.completeWith(result: responseResult)
        wait(for: [exp], timeout: 1.0)
    }

    private func makeTestTarget(file: StaticString = #file, line: UInt = #line)
        -> (RemoteQiitaLoader, HTTPClientSpy) {
            let client = HTTPClientSpy()
            let target = RemoteQiitaLoader(url: anyURL, client: client)
            trackForMemoryLeaks(target, file: file, line: line)
            return (target, client)
    }
}

private func encode(_ items: [QiitaItem]) -> Data {
    try! JSONEncoder().encode(items)
}

