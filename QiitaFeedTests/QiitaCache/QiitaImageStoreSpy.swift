//
//  QiitaImageStoreSpy.swift
//  QiitaFeedTests
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
@testable import QiitaFeed

final class QiitaImageStoreSpy: QiitaImageStore {
    enum ReceivedMessage: Equatable {
        case get(URL)
        case save(URL)
        case delete(URL)
    }

    var receivedMessages: [ReceivedMessage] = []

    var receivedGetCompletions: [URL: GetCompletion] = [:]
    var receivedSaveCompletions: [URL: SaveCompletion] = [:]
    var receivedDeleteCompletions: [URL: DeleteCompletion] = [:]

    func get(for url: URL, completion: @escaping GetCompletion) {
        receivedGetCompletions[url] = completion
        receivedMessages.append(.get(url))
    }

    func completeWith(result: GetResult, for url: URL) {
        receivedGetCompletions[url]!(result)
    }

    func save(url: URL, image: CachedQiitaImage, completion: @escaping SaveCompletion) {
        receivedMessages.append(.save(url))
        receivedSaveCompletions[url] = completion
    }

    func completeSaveWith(result: SaveResult, for url: URL) {
        receivedSaveCompletions[url]!(result)
    }

    func delete(url: URL, completion: @escaping DeleteCompletion) {
        receivedDeleteCompletions[url] = completion
        receivedMessages.append(.delete(url))
    }

    func completeDeleteWith(result: DeleteResult, for url: URL) {
        receivedDeleteCompletions[url]!(result)
    }
}
