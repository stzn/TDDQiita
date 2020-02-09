//
//  QiitaListAcceptanceTests.swift
//  TDDQiitaTests
//
//  Created by Shinzan Takata on 2020/01/02.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
import QiitaFeediOS
@testable import QiitaFeed
@testable import TDDQiita

class QiitaListAcceptanceTests: XCTestCase {
    func testOnLaunchDisplayRemoteQiitaItemWhenUserHasConnectivity() {
        let viewController = launch(httpClient: .online(response))
        viewController.loadViewIfNeeded()
        XCTAssertEqual(viewController.numberOfRows, 2)

        let cell0 = viewController.simulateRenderedViewVisible(at: 0)
        let cell1 = viewController.simulateRenderedViewVisible(at: 1)
        XCTAssertEqual(cell0?.userImage, imageData)
        XCTAssertEqual(cell1?.userImage, imageData)
    }

    func testOnLaunchDisplayLocalQiitaItemWhenUserHasNoConnectivity() {
        let store = InMemoryQiitaStore.empty

        let onlineViewController = launch(httpClient: .online(response), store: store)
        onlineViewController.loadViewIfNeeded()
        onlineViewController.simulateRenderedViewVisible(at: 0)
        onlineViewController.simulateRenderedViewVisible(at: 1)

        let offlineViewController = launch(httpClient: .offline, store: store)
        offlineViewController.loadViewIfNeeded()
        XCTAssertEqual(offlineViewController.numberOfRows, 2)

        let cell0 = offlineViewController.simulateRenderedViewVisible(at: 0)
        let cell1 = offlineViewController.simulateRenderedViewVisible(at: 1)
        XCTAssertEqual(cell0?.userImage, imageData)
        XCTAssertEqual(cell1?.userImage, imageData)
    }

    func testOnLaunchDisplayRemoteQiitaItemWhenUserHasNoCacheAndNoConnectivity() {
        let viewController = launch()
        viewController.loadViewIfNeeded()
        XCTAssertEqual(viewController.numberOfRows, 0)
    }

    func testValidateCacheExpiredCacheWhenEnterBackground() {
        let store = InMemoryQiitaStore.withExpiredCache
        enterBackground(with: store)

        XCTAssertNil(store.item)
        XCTAssertTrue(store.images.isEmpty)
    }

    func testValidateCacheNonExpiredCacheWhenEnterBackground() {
        let store = InMemoryQiitaStore.withNonExpiredCache
        enterBackground(with: store)

        XCTAssertNotNil(store.item)
        XCTAssertFalse(store.images.isEmpty)
    }

    // MARK: - Helpers
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryQiitaStore = .empty
    ) -> QiitaListViewController {
        let scene = SceneDelegate(httpClient: httpClient, store: store)
        scene.window = UIWindow()
        scene.configureWindow()

        // swiftlint:disable:next force_cast
        let nav = scene.window?.rootViewController as! UINavigationController
        // swiftlint:disable:next force_cast
        return nav.topViewController as! QiitaListViewController
    }

    private func enterBackground(with store: QiitaStore & QiitaImageStore) {
        let scene = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        scene.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }

    private func makeData(for url: URL) -> Data {
        if url.absoluteString.contains(baseImageURL) {
            return imageData
        } else {
            return makeCodableQiitaItemData()
        }
    }

    private func makeCodableQiitaItemData() -> Data {
        // swiftlint:disable:next force_try
        try! JSONEncoder().encode([anyCodableQiitaItem, anyCodableQiitaItem])
    }

    private var imageData: Data {
        UIImage.make(color: .blue).pngData()!
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        return (makeData(for: url), anyHTTPURLResponse)
    }

    private let baseImageURL = "https://image.integration.com"
    private var imageURL: String {
        "\(baseImageURL)/\(UUID().uuidString)"
    }

    private var anyCodableQiitaItem: CodableQiitaItem {
        let item = anyQiitaItem
        return CodableQiitaItem(
            id: UUID().uuidString,
            likesCount: item.likesCount,
            reactionsCount: item.reactionsCount,
            commentsCount: item.commentsCount,
            title: item.title,
            createdAt: item.createdAt.string(format: .ISO8601Format),
            updatedAt: item.updatedAt.string(format: .ISO8601Format),
            url: item.url,
            tags: item.tags.map { tag in CodableQiitaItem.Tag(name: tag.name) },
            user: CodableQiitaItem.User(
                githubLoginName: "user",
                profileImageUrl: imageURL))
    }
}

extension InMemoryQiitaStore {
    static var empty: InMemoryQiitaStore {
        InMemoryQiitaStore()
    }

    static var withExpiredCache: InMemoryQiitaStore {
        let timestamp = Date().minusQiitaCacheMaxAge().advanced(by: -1)
        let url = anyURL
        return InMemoryQiitaStore(
            item: CachedQiitaItem(items: [anyQiitaItem], timestamp: timestamp),
            images: [url: CachedQiitaImage(url: url, data: anyData, timestamp: timestamp)])
    }

    static var withNonExpiredCache: InMemoryQiitaStore {
        let timestamp = Date().minusQiitaCacheMaxAge().advanced(by: 1)
        let url = anyURL
        return InMemoryQiitaStore(
            item: CachedQiitaItem(items: [anyQiitaItem], timestamp: timestamp),
            images: [url: CachedQiitaImage(url: url, data: anyData, timestamp: timestamp)])
    }
}
