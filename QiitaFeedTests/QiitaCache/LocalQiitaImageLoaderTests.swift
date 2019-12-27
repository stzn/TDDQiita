//
//  LocalQiitaImageLoaderTests.swift
//  QiitaFeedTests
//
//  Created by shinzan_takata on 2019/12/18.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeed

class LocalQiitaImageLoaderTests: XCTestCase {
    func testInitNoCache() {
        let (_, store) = makeTestTarget()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func testGetCalled() {
        let (loader, store) = makeTestTarget()
        let url = anyURL

        loader.load(url: url) { _ in }

        XCTAssertEqual(store.receivedMessages, [.get(url)])
    }

    func testGetWithoutCacheNotFoundError() {
        let (loader, store) = makeTestTarget()
        let url = anyURL
        expect(loader, expected: .failure(QiitaImageLoaderError.notFound), for: url, when: {
            store.completeWith(result: .success(nil), for: url)
        })

        XCTAssertEqual(store.receivedMessages, [.get(url)])
    }

    func testGetWithCacheDataGot() {
        let (loader, store) = makeTestTarget()
        let currentDate = Date()
        let data = anyData
        let item = CachedQiitaImage(data: data,
                                    timestamp: currentDate.minusQiitaCacheMaxAge().advanced(by: 1))
        let url = anyURL
        expect(loader, expected: .success(data), for: url, when: {
            store.completeWith(result: .success(item), for: url)
        }, currentDate: { currentDate })
    }

    func testGetErrorNoSideEffect() {
        let (loader, store) = makeTestTarget()
        let url = anyURL
        let error = anyNSError

        expect(loader, expected: .failure(error), for: url, when: {
            store.completeWith(result: .failure(error), for: url)
        })
        XCTAssertEqual(store.receivedMessages, [.get(url)])
    }

    func testCancelNoDataFetched() {
        let url = anyURL
        let (loader, store) = makeTestTarget()

        let exp = expectation(description: "expect")
        let task = loader.load(url: url) { _ in
            XCTFail("should not come here")
            exp.fulfill()
        }
        task.cancel()
        store.completeWith(result: .success(anyCachedQiitaImage), for: url)

        let result = XCTWaiter.wait(for: [exp], timeout: 0.5)
        switch result {
        case .timedOut:
            break
        default:
            XCTFail("timeout should occur")
        }
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

    private func expect(_ loader: LocalQiitaImageLoader,
                        expected: LocalQiitaImageLoader.Result, for url: URL,
                        when action: () -> Void,
                        currentDate: @escaping () -> Date = Date.init,
                        file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for get")
        _ = loader.load(url: url) { received in
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

    private var anyCachedQiitaImage: CachedQiitaImage {
        return CachedQiitaImage(data: anyData, timestamp: Date())
    }
}

