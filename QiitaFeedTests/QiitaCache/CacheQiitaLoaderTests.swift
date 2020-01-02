//
//  CacheQiitaLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2020/01/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
@testable import QiitaFeed

class CacheQiitaLoaderTests: XCTestCase {
    func testSaveSuccess() {
        let (loader, store) = makeTestTarget()
        saveExpect(loader, expected: .success(()), with: anyCachedQiitaItem, when: {
            store.completeSaveWith(result: .success(()))
        })
    }

    func testSaveError() {
        let (loader, store) = makeTestTarget()
        let error = anyNSError
        saveExpect(loader, expected: .failure(error), with: anyCachedQiitaItem, when: {
            store.completeSaveWith(result: .failure(error))
        })
    }

    func testDeleteSuccess() {
        let (loader, store) = makeTestTarget()
        deleteExpect(loader, expected: .success(()), when: {
            store.completeDeleteWith(result: .success(()))
        })
    }

    func testDeleteError() {
        let (loader, store) = makeTestTarget()
        let error = anyNSError
        deleteExpect(loader, expected: .failure(error), when: {
            store.completeDeleteWith(result: .failure(error))
        })
    }


    // MARK: Helpers
    private func makeTestTarget(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file, line: UInt = #line) -> (LocalQiitaLoader, QiitaStoreSpy) {
        let store = QiitaStoreSpy()
        let loader = LocalQiitaLoader(store: store, perPageItemsCount: 1)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (loader, store)
    }

    private func saveExpect(_ loader: LocalQiitaLoader,
                            expected: LocalQiitaLoader.SaveResult,
                            with item: CachedQiitaItem,
                            when action: () -> Void,
                            file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        loader.save(item) { received in
            defer { exp.fulfill() }

            switch (received, expected) {
            case (.success, .success):
                break
            case (.failure(let lhs as NSError), .failure(let rhs as NSError)):
                XCTAssertEqual(lhs, rhs, file: file, line: line)
            default:
                XCTFail("except \(expected), but got \(received)", file: file, line: line)
            }
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func deleteExpect(_ loader: LocalQiitaLoader,
                              expected: LocalQiitaLoader.DeleteResult,
                              when action: () -> Void,
                              file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        loader.delete { received in
            defer { exp.fulfill() }

            switch (received, expected) {
            case (.success, .success):
                break
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
