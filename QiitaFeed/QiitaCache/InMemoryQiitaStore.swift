//
//  InMemoryQiitaStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

final class InMemoryQiitaStore: QiitaStore {
    private(set) var item: CachedQiitaItem? = nil

    typealias GetResult = Result<CachedQiitaItem?, Error>
    typealias GetCompletion = (GetResult) -> Void
    func get(completion: @escaping GetCompletion) {
        completion(.success(item))
    }

    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void
    func save(_ item: CachedQiitaItem, completion: @escaping SaveCompletion) {
        self.item = item
        completion(.success(()))
    }

    typealias DeleteResult = Result<Void, Error>
    typealias DeleteCompletion = (DeleteResult) -> Void
    func delete(completion: @escaping DeleteCompletion) {
        self.item = nil
        completion(.success(()))
    }
}
