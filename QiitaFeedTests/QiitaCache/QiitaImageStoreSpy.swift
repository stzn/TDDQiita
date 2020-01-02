//
//  QiitaImageStoreSpy.swift
//  QiitaFeedTests
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature
@testable import QiitaFeed

final class QiitaImageStoreSpy: QiitaImageStore {
    enum ReceivedMessage: Equatable {
        case get(URL)
        case getAll
        case save(URL)
        case delete(URL)
    }

    var receivedMessages: [ReceivedMessage] = []

    var receivedGetCompletions: [URL: GetCompletion] = [:]
    var receivedGetAllCompletions: [GetAllCompletion] = []
    var receivedSaveCompletions: [URL: SaveCompletion] = [:]
    var receivedDeleteCompletions: [URL: DeleteCompletion] = [:]

    func get(for url: URL, completion: @escaping GetCompletion) {
        receivedGetCompletions[url] = completion
        receivedMessages.append(.get(url))
    }

    func completeWith(result: GetResult, for url: URL) {
        receivedGetCompletions[url]!(result)
    }

    func getAll(completion: @escaping GetAllCompletion) {
        receivedGetAllCompletions.append(completion)
    }

    func completeWith(result: GetAllResult, at index: Int) {
        receivedGetAllCompletions[index](result)
    }

    func save(for url: URL, image: CachedQiitaImage, completion: @escaping SaveCompletion) {
        receivedMessages.append(.save(url))
        receivedSaveCompletions[url] = completion
    }

    func completeSaveWith(result: SaveResult, for url: URL) {
        receivedSaveCompletions[url]!(result)
    }

    func delete(for url: URL, completion: @escaping DeleteCompletion) {
        receivedDeleteCompletions[url] = completion
        receivedMessages.append(.delete(url))
    }

    func completeDeleteWith(result: DeleteResult, for url: URL) {
        receivedDeleteCompletions[url]!(result)
    }
}
