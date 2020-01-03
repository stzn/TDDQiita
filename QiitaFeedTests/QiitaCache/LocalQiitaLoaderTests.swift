//
//  LocalQiitaLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2020/01/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeed

class LocalQiitaLoaderTests: XCTestCase {
    func testInitNoCache() {
        let (_, store) = makeTestTarget()
        XCTAssertEqual(store.receivedMessages.count, 0)
    }

    func testLoadNextWithoutCacheNoItemGot() {
        let (loader, store) = makeTestTarget()
        expectLoadNext(loader, expected: .success([]), when: {
            store.completeWith(.success(nil))
        })
    }

    func testRefreshWithoutCacheNoItemGot() {
        let (loader, store) = makeTestTarget()
        expectRefresh(loader, expected: .success([]), when: {
            store.completeWith(.success(nil))
        })
    }

    func testLoadNextErrorNoItemGot() {
        let (loader, store) = makeTestTarget()
        let error = anyNSError
        expectLoadNext(loader, expected: .failure(error), when: {
            store.completeWith(.failure(error))
        })
    }

    func testRefreshErrorNoItemGot() {
        let (loader, store) = makeTestTarget()
        let error = anyNSError
        expectLoadNext(loader, expected: .failure(error), when: {
            store.completeWith(.failure(error))
        })
    }

    func testLoadNextWithValidCacheItemGot() {
        let currentDate = Date()
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: 1)
        let items: [QiitaItem] = (0..<3).map { _ in anyQiitaItem }
        let item = CachedQiitaItem(items: items, timestamp: timestamp)
        let (loader, store) = makeTestTarget()
        expectLoadNext(loader, expected: .success([item.items[0]]), when: {
            store.save(item) { _ in }
            store.completeWith(.success(item))
        }, currentDate: { currentDate })
        expectLoadNext(loader, expected: .success([item.items[1]]),
                       when: {}, currentDate: { currentDate })
        expectLoadNext(loader, expected: .success([item.items[2]]),
                       when: {}, currentDate: { currentDate })
    }

    func testLoadNextWithInvalidNoItemGot() {
        let currentDate = Date()
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: -1)
        let items = [anyQiitaItem]
        let item = CachedQiitaItem(items: items, timestamp: timestamp)
        let (loader, store) = makeTestTarget()
        expectLoadNext(loader, expected: .success([]), when: {
            store.save(item) { _ in }
            store.completeWith(.success(item))
        }, currentDate: { currentDate })
    }

    func testRefreshWithValidCacheItemGot() {
        let currentDate = Date()
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: 1)
        let items = [anyQiitaItem, anyQiitaItem]
        let item = CachedQiitaItem(items: items, timestamp: timestamp)
        let (loader, store) = makeTestTarget()
        expectLoadNext(loader, expected: .success([item.items[0]]), when: {
            store.save(item) { _ in }
            store.completeWith(.success(item), at: 0)
        }, currentDate: { currentDate })
        expectRefresh(loader, expected: .success([item.items[0]]), when: {
            store.completeWith(.success(item), at: 1)
        }, currentDate: { currentDate })
    }

    func testRefreshWithInvalidNoItemGot() {
        let currentDate = Date()
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: -1)
        let items = [anyQiitaItem, anyQiitaItem]
        let item = CachedQiitaItem(items: items, timestamp: timestamp)
        let (loader, store) = makeTestTarget()
        expectRefresh(loader, expected: .success([]), when: {
            store.save(item) { _ in }
            store.completeWith(.success(item))
        }, currentDate: { currentDate })
    }

    // MARK: Helpers
    private func makeTestTarget(currentDate: @escaping () -> Date = Date.init,
                                file: StaticString = #file, line: UInt = #line)
        -> (LocalQiitaLoader, QiitaStoreSpy) {
            let store = QiitaStoreSpy()
            let loader = LocalQiitaLoader(
                store: store, perPageItemsCount: 1, currentDate: currentDate)
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(store, file: file, line: line)
            return (loader, store)
    }

    private func expectLoadNext(_ loader: LocalQiitaLoader,
                                expected: QiitaLoader.Result,
                                when action: () -> Void,
                                currentDate: @escaping () -> Date = Date.init,
                                file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load next")
        loader.loadNext { [weak self] received in
            self?.assertResult(
                received: received, expected: expected)
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func expectRefresh(_ loader: LocalQiitaLoader,
                               expected: QiitaLoader.Result,
                               when action: () -> Void,
                               currentDate: @escaping () -> Date = Date.init,
                               file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for refresh")
        loader.refresh { [weak self] received in
            self?.assertResult(
                received: received, expected: expected)
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func assertResult(
        received: PaginationQiitaLoader.Result,
        expected: PaginationQiitaLoader.Result,
        file: StaticString = #file, line: UInt = #line) {

        switch (received, expected) {
        case (.success(let lhs), .success(let rhs)):
            XCTAssertEqual(lhs, rhs, file: file, line: line)
        case (.failure(let lhs as NSError), .failure(let rhs as NSError)):
            XCTAssertEqual(lhs, rhs, file: file, line: line)
        default:
            XCTFail("except \(expected), but got \(received)", file: file, line: line)
        }
    }
}
