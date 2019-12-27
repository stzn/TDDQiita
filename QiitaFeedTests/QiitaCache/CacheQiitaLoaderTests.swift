//
//  CacheQiitaLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/21.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeed

class CacheQiitaLoaderTests: XCTestCase {
    func testSaveSuccess() {
        let (loader, store) = makeTestTarget()
        saveExpect(loader, expected: .success(()), when: {
            store.completeSaveWith(result: .success(()))
        }, with: anyCachedQiitaItem)
    }

    func testSaveError() {
        let (loader, store) = makeTestTarget()
        let error = anyNSError
        saveExpect(loader, expected: .failure(error), when: {
            store.completeSaveWith(result: .failure(error))
        }, with: anyCachedQiitaItem)
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
    private func makeTestTarget(currentDate: @escaping () -> Date = Date.init,
                                file: StaticString = #file, line: UInt = #line)
        -> (LocalQiitaLoader, QiitaStoreSpy) {
            let store = QiitaStoreSpy()
            let loader = LocalQiitaLoader(store: store, currentDate: currentDate)
            trackForMemoryLeaks(loader, file: file, line: line)
            trackForMemoryLeaks(store, file: file, line: line)
            return (loader, store)
    }

    private func saveExpect(_ loader: LocalQiitaLoader,
                            expected: QiitaStore.SaveResult,
                            when action: () -> Void,
                            with item: CachedQiitaItem,
                            file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait save")
        loader.save(item) { received in
            defer { exp.fulfill() }

            switch (received, expected) {
            case (.success, .success):
                break
            case (.failure(let lError), .failure(let rError)):
                XCTAssertTrue(lError.localizedDescription == rError.localizedDescription)
            default:
                XCTFail("expect \(expected), but got \(received)")
            }
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func deleteExpect(_ loader: LocalQiitaLoader,
                              expected: QiitaStore.DeleteResult,
                              when action: () -> Void,
                              file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait delete")
        loader.delete { received in
            defer { exp.fulfill() }

            switch (received, expected) {
            case (.success, .success):
                break
            case (.failure(let lError), .failure(let rError)):
                XCTAssertTrue(lError.localizedDescription == rError.localizedDescription)
            default:
                XCTFail("expect \(expected), but got \(received)")
            }
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
