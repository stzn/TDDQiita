//
//  LocalQiitaLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
@testable import QiitaFeed

class LocalQiitaLoaderTests: XCTestCase {
    func testInitNoCache() {
        let (_, store) = makeTestTarget()
        XCTAssertEqual(store.receivedMessages.count, 0)
    }

    func testGetWithoutCacheNoItemGot() {
        let (loader, store) = makeTestTarget()
        expect(loader, expected: .success([]), when: {
            store.completeWith(.success(nil))
        })
    }

    func testGetErrorNoItemGot() {
        let (loader, store) = makeTestTarget()
        let error = anyNSError
        expect(loader, expected: .failure(error), when: {
            store.completeWith(.failure(error))
        })
    }

    func testGetWithNotExpiredCacheItemGot() {
        let currentDate = Date()
        let timestamp = currentDate.minusQiitaCacheMaxAge()
        let items = [anyQiitaItem]
        let item = CachedQiitaItem(items: items, timestamp: timestamp)
        let (loader, store) = makeTestTarget()
        expect(loader, expected: .success([]), when: {
            store.save(item) { _ in }
            store.completeWith(.success(item))
        }, currentDate: { currentDate })
    }

    func testGetWithExpiredCacheNoItemGot() {
        let currentDate = Date()
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: 1)
        let item = CachedQiitaItem(items: [anyQiitaItem], timestamp: timestamp)
        let (loader, store) = makeTestTarget()
        expect(loader, expected: .success(item.items), when: {
            store.save(item) { _ in }
            store.completeWith(.success(item))
        }, currentDate: { currentDate })
    }

    // MARK: Helpers
    private func makeTestTarget(currentDate: @escaping () -> Date = Date.init,
                                file: StaticString = #file, line: UInt = #line)
        -> (LocalQiitaLoader, QiitaStoreSpy) {
            let store = QiitaStoreSpy()
            let loader = LocalQiitaLoader(store: store, currentDate: currentDate)
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(store, file: file, line: line)
            return (loader, store)
    }

    private func expect(_ loader: LocalQiitaLoader,
                        expected: QiitaLoader.Result,
                        when action: () -> Void,
                        currentDate: @escaping () -> Date = Date.init,
                        file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for get")
        loader.load { received in
            defer { exp.fulfill() }

            switch (received, expected) {
            case (.success(let lhs), .success(let rhs)):
                XCTAssertEqual(lhs, rhs, file: file, line: line)
            case (.failure(let lhs as NSError), .failure(let rhs as NSError)):
                XCTAssertEqual(lhs, rhs, file: file, line: line)
            default:
                XCTFail("except \(expected), but got \(received)", file: file, line: line)
            }
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
