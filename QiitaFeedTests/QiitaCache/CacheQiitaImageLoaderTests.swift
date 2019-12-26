//
//  CacheQiitaImageLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/21.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
@testable import QiitaFeed

class CacheQiitaImageLoaderTests: XCTestCase {
    func testSaveSuccess() {
        let (loader, store) = makeTestTarget()
        let url = anyURL
        saveExpect(loader, expected: .success(()), for: url, data: anyData, when: {
            store.completeSaveWith(result: .success(()), for: url)
        })
    }

    func testSaveError() {
        let (loader, store) = makeTestTarget()
        let url = anyURL
        let error = anyNSError
        saveExpect(loader, expected: .failure(error), for: url, data: anyData, when: {
            store.completeSaveWith(result: .failure(error), for: url)
        })
    }

    func testDeleteSuccess() {
        let (loader, store) = makeTestTarget()
        let url = anyURL
        deleteExpect(loader, expected: .success(()), for: url, when: {
            store.completeDeleteWith(result: .success(()), for: url)
        })
    }

    func testDeleteError() {
        let (loader, store) = makeTestTarget()
        let url = anyURL
        let error = anyNSError
        deleteExpect(loader, expected: .failure(error), for: url, when: {
            store.completeDeleteWith(result: .failure(error), for: url)
        })
    }


    // MARK: Helpers
    private func makeTestTarget(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file, line: UInt = #line) -> (LocalQiitaImageLoader, QiitaImageStoreSpy) {
        let store = QiitaImageStoreSpy()
        let loader = LocalQiitaImageLoader(store: store)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (loader, store)
    }

    private func saveExpect(_ loader: LocalQiitaImageLoader,
                            expected: LocalQiitaImageLoader.SaveResult,
                            for url: URL, data: Data,
                            when action: () -> Void,
                            file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        loader.save(for: url, data: data) { received in
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

    private func deleteExpect(_ loader: LocalQiitaImageLoader,
                              expected: LocalQiitaImageLoader.SaveResult,
                              for url: URL,
                              when action: () -> Void,
                              file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        loader.delete(for: url) { received in
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
