//
//  PaginationRemoteQiitaLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2020/01/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeed

class RemoteQiitaLoaderTests: XCTestCase {
    typealias Error = RemoteQiitaLoader.Error

    func testLoadNextItemGot() {
        let (loader, client) = makeTestTarget()
        let item = anyQiitaItem
        let codableItem = converToCodableItem(from: item)
        expectLoadNext(loader, expected: .success([item]), when: {
            client.completeWith(
                result: .success((encode([codableItem]), anyHTTPURLResponse))
            )
        })
    }

    func testLoadNextHasNextPage() {
        let (loader, client) = makeTestTarget()
        let items = [anyQiitaItem, anyQiitaItem]
        let codableItems = items.map(converToCodableItem(from:))
        expectLoadNext(loader, expected: .success(items), when: {
            client.completeWith(
                result: .success((encode(codableItems), anyHTTPURLResponse))
            )
        })
        XCTAssertEqual(loader.shouldLoadNext, true)
    }

    func testLoadNextNotHasNextPage() {
        let (loader, client) = makeTestTarget(perPageItemsCount: 3)
        let items = [anyQiitaItem, anyQiitaItem]
        let codableItems = items.map(converToCodableItem(from:))
        expectLoadNext(loader, expected: .success(items), when: {
            client.completeWith(
                result: .success((encode(codableItems), anyHTTPURLResponse))
            )
        })
        XCTAssertEqual(loader.shouldLoadNext, false)
    }

    func testRefreshItemGot() {
        let (loader, client) = makeTestTarget()
        let item = anyQiitaItem
        let codableItem = converToCodableItem(from: item)
        expectRefresh(loader, expected: .success([item]), when: {
            client.completeWith(
                result: .success((encode([codableItem]), anyHTTPURLResponse))
            )
        })
    }

    func testLoadNextMultipleItemGot() {
        let (loader, client) = makeTestTarget()
        let items = [anyQiitaItem, anyQiitaItem]
        let codableItems = items.map(converToCodableItem(from:))
        expectLoadNext(loader, expected: .success(items), when: {
            client.completeWith(
                result: .success((encode(codableItems), anyHTTPURLResponse))
            )
        })
    }

    func testRefreshMultipleItemGot() {
        let (loader, client) = makeTestTarget()
        let items = [anyQiitaItem, anyQiitaItem]
        let codableItems = items.map(converToCodableItem(from:))
        expectRefresh(loader, expected: .success(items), when: {
            client.completeWith(
                result: .success((encode(codableItems), anyHTTPURLResponse))
            )
        })
    }

    func testLoadNextEmptyNoItemGot() {
        let (loader, client) = makeTestTarget()
        expectLoadNext(loader, expected: .success([]), when: {
            client.completeWith(
                result: .success((encode([]), anyHTTPURLResponse)))
        })
    }

    func testLoadNextLoadError() {
        let (loader, client) = makeTestTarget()
        expectLoadNext(loader, expected: .failure(Error.connectivity), when: {
            client.completeWith(
                result: .failure(HTTPClientError.noData))
        })
    }

    func testLoadNextDecodeError() {
        let (loader, client) = makeTestTarget()
        expectLoadNext(loader, expected: .failure(RemoteQiitaLoader.Error.invalidData), when: {
            client.completeWith(
                result: .success((anyData, anyHTTPURLResponse)))
        })
    }

    func testQueryParameter() {
        let (loader, client) = makeTestTarget()
        loader.loadNext { _ in }

        guard let url = client.receivedValues.first?.url else {
            XCTFail("url must not be nil")
            return
        }
        assertQueryParameters(url: url, parameters: [
            RemoteQiitaLoader.QueryKey.pageNumber: 1,
            RemoteQiitaLoader.QueryKey.perPageItemsCount: loader.perPageItemsCount
        ])
    }

    // MARK: Helpers
    private func makeTestTarget(
        perPageItemsCount: Int = 1,
        file: StaticString = #file, line: UInt = #line)
        -> (RemoteQiitaLoader, HTTPClientSpy) {
            let client = HTTPClientSpy()
            let target = RemoteQiitaLoader(
                client: client, baseURL: anyURL,
                perPageItemsCount: perPageItemsCount)
            trackForMemoryLeaks(target, file: file, line: line)
            return (target, client)
    }

    typealias Assert = (RemoteQiitaLoader.Result, RemoteQiitaLoader.Result) -> Bool

    private func expectLoadNext(_ loader: RemoteQiitaLoader,
                                expected: PaginationQiitaLoader.Result,
                                when action: () -> Void,
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

    private func expectRefresh(_ loader: RemoteQiitaLoader,
                               expected: PaginationQiitaLoader.Result,
                               when action: () -> Void,
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

    private func assertQueryParameters(
        url: URL, parameters: [String: Any],
        file: StaticString = #file, line: UInt = #line) {

        for (key, value) in parameters {
            assertQueryParameter(url: url.absoluteString, key: key, value: value, file: file, line: line)
        }
    }

    private func assertQueryParameter(
        url: String, key: String, value: Any,
        file: StaticString = #file, line: UInt = #line) {
        guard let url = URLComponents(string: url) else {
            XCTFail("invalid url", file: file, line: line)
            return
        }
        let paramValue = url.queryItems?.first(where: { $0.name == key })?.value
        XCTAssertEqual(String(describing: paramValue!),
                       String(describing: value), file: file, line: line)
    }

    private func encode(_ items: [CodableQiitaItem]) -> Data {
        // swiftlint:disable:next force_try
        try! JSONEncoder().encode(items)
    }

    private func converToCodableItem(from item: QiitaItem) -> CodableQiitaItem {
        var user: CodableQiitaItem.User?
        if let itemUser = item.user {
            user = CodableQiitaItem.User(
                githubLoginName: itemUser.githubLoginName, profileImageUrl: itemUser.profileImageUrl)
        }
        return CodableQiitaItem(
            id: item.id,
            likesCount: item.likesCount,
            reactionsCount: item.reactionsCount,
            commentsCount: item.commentsCount,
            title: item.title,
            createdAt: item.createdAt.string(format: .ISO8601Format),
            updatedAt: item.updatedAt.string(format: .ISO8601Format),
            url: item.url,
            tags: item.tags.map { tag in CodableQiitaItem.Tag(name: tag.name) },
            user: user)
    }
}
