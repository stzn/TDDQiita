//
//  SceneDelegateTests.swift
//  TDDQiitaTests
//
//  Created by Shinzan Takata on 2020/01/02.
//  Copyright © 2020 shiz. All rights reserved.
//

import XCTest
import QiitaFeediOS
@testable import TDDQiita

class SceneDelegateTests: XCTestCase {
    func testSceneWillConnectToSessionConfigureRootViewController() {
        let scene = SceneDelegate()
        scene.window = UIWindow()

        scene.configureWindow()

        let root = scene.window?.rootViewController

        XCTAssertTrue(root is UINavigationController)
    }
}
