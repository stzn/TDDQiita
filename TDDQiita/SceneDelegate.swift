//
//  SceneDelegate.swift
//  TDDQiita
//
//  Created by Shinzan Takata on 2019/12/14.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit
import QiitaFeature
import QiitaFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient()
    }()

    private lazy var store: QiitaStore & QiitaImageStore = {
        InMemoryQiitaStore()
    }()

    private let perPageItemsCount = 30
    private lazy var localQiitaLoader: LocalQiitaLoader = {
        LocalQiitaLoader(store: store, perPageItemsCount: perPageItemsCount,
                         currentDate: Date.init)
    }()

    private lazy var localQiitaImageLoader: LocalQiitaImageLoader = {
        LocalQiitaImageLoader(store: store, currentDate: Date.init)
    }()

    convenience init(httpClient: HTTPClient, store: QiitaStore & QiitaImageStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        configureWindow()
    }

    func configureWindow() {
        let qiitaURL = URL(string: "https://qiita.com/api/v2/items")!
        let remoteQiitaLoader = RemoteQiitaLoader(client: httpClient, baseURL: qiitaURL, perPageItemsCount: perPageItemsCount)
        let remoteQiitaImageLoader = RemoteQiitaImageLoader(client: httpClient)

        window?.rootViewController = QiitaListUIComposer.composeQiitaListViewController(
            listLoader: PaginationQiitaLoaderWithFallback(
                primary: QiitaCacheDecorator(decoratee: remoteQiitaLoader,
                                             cache: localQiitaLoader),
                fallback: localQiitaLoader),
            imageLoader: QiitaImageLoaderWithFallback(
                primary: QiitaImageCacheDecorator(decoratee: remoteQiitaImageLoader,
                                                  cache: localQiitaImageLoader),
                fallback: localQiitaImageLoader))
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localQiitaLoader.validateCache()
        localQiitaImageLoader.validateCache()
    }
}

