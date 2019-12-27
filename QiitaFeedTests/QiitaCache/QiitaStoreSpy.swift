//
//  QiitaStoreSpy.swift
//  QiitaFeedTests
//
//  Created by shinzan_takata on 2019/12/18.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature
@testable import QiitaFeed

final class QiitaStoreSpy: QiitaStore {
    enum ReceivedMessage: Equatable {
        case get
        case save(CachedQiitaItem)
        case delete
    }

    private(set) var receivedMessages: [ReceivedMessage] = []
    var receivedGetCompletions: [GetCompletion] = []
    var receivedSaveCompletions: [SaveCompletion] = []
    var receivedDeleteCompletions: [DeleteCompletion] = []

    func get(completion: @escaping GetCompletion) {
        receivedMessages.append(.get)
        receivedGetCompletions.append(completion)
    }

    func completeWith(_ result: QiitaStore.GetResult, at index: Int = 0) {
        receivedGetCompletions[index](result)
    }

    func save(_ item: CachedQiitaItem, completion: @escaping QiitaStore.SaveCompletion) {
        receivedMessages.append(.save(item))
        receivedSaveCompletions.append(completion)
    }

    func completeSaveWith(result: SaveResult, at index: Int = 0) {
        receivedSaveCompletions[index](result)
    }

    func delete(completion: @escaping QiitaStore.DeleteCompletion) {
        receivedMessages.append(.delete)
        receivedDeleteCompletions.append(completion)
    }

    func completeDeleteWith(result: DeleteResult, at index: Int = 0) {
        receivedDeleteCompletions[index](result)
    }
}

