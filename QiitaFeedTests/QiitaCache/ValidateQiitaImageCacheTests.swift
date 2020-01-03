//
//  ValidateQiitaImageCacheTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2020/01/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeed

class ValidateQiitaImageCacheTests: XCTestCase {
    func testInitNoCache() {
        let (_, store) = makeTestTarget()
        XCTAssertEqual(store.receivedMessages.count, 0)
    }

    func testValidateCacheWithNoExpiredCache() {
        let (loader, store) = makeTestTarget()
        let currentDate = Date()
        let url = anyURL
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: 1)
        let image = CachedQiitaImage(url: url, data: anyData, timestamp: timestamp)
        loader.validateCache()
        store.completeWith(result: .success([image]))
        XCTAssertEqual(store.receivedMessages, [.getAll])
    }

    func testValidateCacheWithExpiredCache() {
        let (loader, store) = makeTestTarget()
        let currentDate = Date()
        let url = anyURL
        let timestamp = currentDate.minusQiitaCacheMaxAge().advanced(by: -1)
        let image = CachedQiitaImage(url: url, data: anyData, timestamp: timestamp)
        loader.validateCache()
        store.completeWith(result: .success([image]))
        XCTAssertEqual(store.receivedMessages, [.getAll, .delete(url)])
    }

    func testValidateCacheWithGetErrorAllCacheDelete() {
        let (loader, store) = makeTestTarget()
        loader.validateCache()
        store.completeWith(result: .failure(anyNSError))
        XCTAssertEqual(store.receivedMessages, [.getAll, .deleteAll])
    }

    // MARK: Helpers
    private func makeTestTarget(currentDate: @escaping () -> Date = Date.init,
                                file: StaticString = #file, line: UInt = #line)
        -> (LocalQiitaImageLoader, QiitaImageStoreSpy) {
            let store = QiitaImageStoreSpy()
            let loader = LocalQiitaImageLoader(store: store, currentDate: currentDate)
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(store, file: file, line: line)
            return (loader, store)
    }
}
