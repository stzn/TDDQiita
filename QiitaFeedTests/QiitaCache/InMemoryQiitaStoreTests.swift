//
//  InMemoryQiitaStoreTests.swift
//  QiitaFeedTests
//
//  Created by shinzan_takata on 2019/12/18.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
@testable import QiitaFeed

class InMemoryQiitaStoreTests: XCTestCase {
    func testInitNoItemStored() {
        let store = makeTestTarget()
        XCTAssertNil(store.item)
    }

    func testGetWithoutCacheNoItemGot() {
        let store = InMemoryQiitaStore()

        let item = get(store: store)

        XCTAssertNil(item)
    }

    func testGetWithCacheItemGot() {
        let store = InMemoryQiitaStore()
        let item = anyCachedQiitaItem

        save(item: item, store: store)
        let receivedItem = get(store: store)

        XCTAssertEqual(item, receivedItem)
    }

    func testSaveSuccess() {
        let store = makeTestTarget()
        let item = anyCachedQiitaItem

        save(item: item, store: store)

        XCTAssertEqual(store.item, item)
    }

    func testDeleteSuccess() {
        let store = makeTestTarget()

        save(item: anyCachedQiitaItem, store: store)
        delete(store: store)

        XCTAssertNil(store.item)
    }

    // MARK: Helpers
    private func makeTestTarget() -> InMemoryQiitaStore {
        let store = InMemoryQiitaStore()
        trackForMemoryLeaks(store)
        return store
    }

    private func get(store: InMemoryQiitaStore) -> CachedQiitaItem? {
        var received: CachedQiitaItem?
        store.get { item in
            received = try! item.get()
        }
        return received
    }

    private func save(item: CachedQiitaItem, store: InMemoryQiitaStore) {
        let exp = expectation(description: "wait save")
        store.save(item) { result in
            if case .failure = result {
                XCTFail("expect success, but got \(result)")
                return
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func delete(store: InMemoryQiitaStore) {
        let exp = expectation(description: "wait delete")
        store.delete { result in
            if case .failure = result {
                XCTFail("expect success, but got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
