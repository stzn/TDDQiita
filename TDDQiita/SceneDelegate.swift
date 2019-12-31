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
import QiitaFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient()
    }()

    private lazy var store: QiitaStore = {
        InMemoryQiitaStore()
    }()

    private lazy var imageStore: QiitaImageStore = {
        InMemoryQiitaImageStore()
    }()

    private lazy var remoteQiitaLoader: RemoteQiitaLoader = {
        RemoteQiitaLoader(url: URL(string: "https://qiita.com/api/v2/items")!,
                          client: httpClient)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        configureWindow()
    }

    func configureWindow() {
        let qiitaURL = URL(string: "https://qiita.com/api/v2/items")!
        let remoteQiitaLoader = RemoteQiitaLoader(url: qiitaURL, client: httpClient)
        let remoteQiitaImageLoader = RemoteQiitaImageLoader(client: httpClient)
//        let localQiitaLoader = LocalQiitaLoader(store: store, currentDate: Date.init)
//        let localQiitaImageLoader = LocalQiitaImageLoader(store: imageStore, currentDate: Date.init)

        window?.rootViewController = QiitaListUIComposer.composeQiitaListViewController(listLoader: remoteQiitaLoader, imageLoader: remoteQiitaImageLoader)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

