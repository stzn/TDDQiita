//
//  QiitaLoaderTests.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/14.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeed

class RemoteQiitaLoaderTests: XCTestCase {
    func testFetchItemsFetched() {
        let item = anyQiitaItem
        var user: CodableQiitaItem.User? = nil
        if let itemUser = item.user {
            user = CodableQiitaItem.User(
                githubLoginName: itemUser.githubLoginName, profileImageUrl: itemUser.profileImageUrl)
        }
        let codableItem = CodableQiitaItem(
            id: item.id, likesCount: item.likesCount, reactionsCount: item.reactionsCount, commentsCount: item.commentsCount, title: item.title, createdAt: item.createdAt.string(format: .ISO8601Format), updatedAt: item.updatedAt.string(format: .ISO8601Format), url: item.url, tags: item.tags.map { tag in CodableQiitaItem.Tag(name: tag.name) }, user: user)
        expect([item], responseResult: .success((encode([codableItem]), anyHTTPURLResponse)))
    }

    func testFetchEmptyNoItemFetched() {
        expect([], responseResult: .success((encode([]), anyHTTPURLResponse)))
    }

    func testFetchLoadError() {
        expectError(.connectivity,
                    responseResult: .failure(HTTPClientError.noData))
    }

    func testFetchDecodeError() {
        expectError(.invalidData,
                    responseResult: .success((anyData, anyHTTPURLResponse)))
    }

    func testQueryParameter() {
        let (loader, client) = makeTestTarget()
        loader.load { _ in }

        guard let url = client.receivedValues.first?.url else {
            XCTFail("url must not be nil")
            return
        }
        assertQueryParameters(url: url, parameters: [
            RemoteQiitaLoader.QueryKey.pageNumber: 1,
            RemoteQiitaLoader.QueryKey.perPageCount: loader.perPageCount
        ])
    }

    // MARK: Helpers
    typealias Assert = (RemoteQiitaLoader.Result, RemoteQiitaLoader.Result) -> Bool

    private func expect(_ expected: [QiitaItem],
                        responseResult: HTTPClient.Result,
                        file: StaticString = #file, line: UInt = #line) {
        let (loader, client) = makeTestTarget(file: file, line: line)
        let exp = expectation(description: "expect")
        loader.load { received in
            defer { exp.fulfill() }

            switch received {
            case .success(let items):
                XCTAssertEqual(items, expected, file: file, line: line)
            case .failure:
                XCTFail("\(expected) want but got \(received)", file: file, line: line)
            }
        }
        client.completeWith(result: responseResult)
        wait(for: [exp], timeout: 1.0)
    }

    private func expectError(_ expected: RemoteQiitaLoader.Error,
                        responseResult: HTTPClient.Result,
                        file: StaticString = #file, line: UInt = #line) {
        let (loader, client) = makeTestTarget(file: file, line: line)
        let exp = expectation(description: "expect error")
        loader.load { received in
            defer { exp.fulfill() }

            if case .failure(let error) = received {
                XCTAssertEqual(error as? RemoteQiitaLoader.Error, expected)
            } else {
                XCTFail("failure want but got \(received)")
            }
        }
        client.completeWith(result: responseResult)
        wait(for: [exp], timeout: 1.0)
    }

    private func makeTestTarget(file: StaticString = #file, line: UInt = #line)
        -> (RemoteQiitaLoader, HTTPClientSpy) {
            let client = HTTPClientSpy()
            let target = RemoteQiitaLoader(url: anyURL, client: client)
            trackForMemoryLeaks(target, file: file, line: line)
            return (target, client)
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

    private var anyCodableQiitaItem: CodableQiitaItem {
        CodableQiitaItem(
            id: UUID().uuidString,
            likesCount: 1, reactionsCount: 1, commentsCount: 1, title: "title",
            createdAt: Date().string(format: .ISO8601Format),
            updatedAt: Date().string(format: .ISO8601Format), url: anyURL,
            tags: [CodableQiitaItem.Tag(name: "tag")], user: nil)
    }

    private func encode(_ items: [CodableQiitaItem]) -> Data {
        try! JSONEncoder().encode(items)
    }
}

extension QiitaItem: Equatable {
    static func ==(lhs: QiitaItem, rhs: QiitaItem) -> Bool {
        return lhs.id == rhs.id
            && lhs.likesCount == rhs.likesCount
            && lhs.reactionsCount == rhs.reactionsCount
            && lhs.commentsCount == rhs.commentsCount
            && lhs.title == rhs.title
            && String(describing: lhs.createdAt) == String(describing: rhs.createdAt)
            && String(describing: lhs.updatedAt) == String(describing: rhs.updatedAt)
            && lhs.url == rhs.url
            && lhs.tags == rhs.tags
            && lhs.user == rhs.user
    }
}
extension QiitaItem.Tag: Equatable{}
extension QiitaItem.User: Equatable {}

