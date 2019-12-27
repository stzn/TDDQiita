//
//  QiitaLoaderSpy.swift
//  QiitaFeediOSTests
//
//  Created by shinzan_takata on 2019/12/25.
//  Copyright © 2019 shiz. All rights reserved.
//

import XCTest
import QiitaFeature
@testable import QiitaFeediOS

final class QiitaLoaderSpy: QiitaLoader, QiitaImageLoader {
    private(set) var canceledURLs: [URL] = []
    private struct Task: QiitaImageLoaderTask {
        let callback: () -> Void
        func cancel() {
            callback()
        }
    }

    var receivedURLs: [URL] {
        receivedMessages.map { $0.0 }
    }
    var receivedMessages: [(url: URL, completion: QiitaImageLoader.Completion)] = []
    func load(url: URL, completion: @escaping QiitaImageLoader.Completion) -> QiitaImageLoaderTask {
        receivedMessages.append((url, completion))
        return Task { [weak self] in
            self?.canceledURLs.append(url)
        }
    }

    func completeImageLoad(with result: QiitaImageLoader.Result, at index: Int = 0) {
        receivedMessages[index].completion(result)
    }

    var receivedCompletions: [QiitaLoader.Completion] = []
    func load(completion: @escaping QiitaLoader.Completion) {
        receivedCompletions.append(completion)
    }

    func complete(with result: QiitaLoader.Result, at index: Int = 0) {
        receivedCompletions[index](result)
    }
}
