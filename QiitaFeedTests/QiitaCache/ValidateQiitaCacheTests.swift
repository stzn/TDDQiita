//
//  LocalQiitaCachePolicyTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/21.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeed

class ValidateQiitaCacheTests: XCTestCase {
    func testInitNoCache() {
        let (_, store) = makeTestTarget()
        XCTAssertEqual(store.receivedMessages.count, 0)
    }

    func testValidateCacheWithNonExpiredCache() {
        let (loader, store) = makeTestTarget()
        let currentDate = Date()
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: 1)
        let item = CachedQiitaItem(items: [anyQiitaItem], timestamp: timestamp)
        loader.validateCache()
        store.completeWith(.success(item))
        XCTAssertEqual(store.receivedMessages, [.get])
    }

    func testValidateCacheWithExpiredCache() {
        let (loader, store) = makeTestTarget()
        let currentDate = Date()
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: -1)
        let item = CachedQiitaItem(items: [anyQiitaItem], timestamp: timestamp)
        loader.validateCache()
        store.completeWith(.success(item))
        XCTAssertEqual(store.receivedMessages, [.get, .delete])
    }

    func testValidateCacheWithGetError() {
        let (loader, store) = makeTestTarget()
        loader.validateCache()
        store.completeWith(.failure(anyNSError))
        XCTAssertEqual(store.receivedMessages, [.get, .delete])
    }

    // MARK: Helpers
    private func makeTestTarget(currentDate: @escaping () -> Date = Date.init,
                                file: StaticString = #file, line: UInt = #line)
        -> (LocalQiitaLoader, QiitaStoreSpy) {
            let store = QiitaStoreSpy()
            let loader = LocalQiitaLoader(store: store, perPageItemsCount: 1,
                                                    currentDate: currentDate)
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(store, file: file, line: line)
            return (loader, store)
    }
}
