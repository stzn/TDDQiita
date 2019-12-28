//
//  InMemoryQiitaStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

public final class InMemoryQiitaStore: QiitaStore {
    public init() {}

    private(set) var item: CachedQiitaItem? = nil

    public typealias GetResult = Result<CachedQiitaItem?, Error>
    public typealias GetCompletion = (GetResult) -> Void
    public func get(completion: @escaping GetCompletion) {
        completion(.success(item))
    }

    public typealias SaveResult = Result<Void, Error>
    public typealias SaveCompletion = (SaveResult) -> Void
    public func save(_ item: CachedQiitaItem, completion: @escaping SaveCompletion) {
        self.item = item
        completion(.success(()))
    }

    public typealias DeleteResult = Result<Void, Error>
    public typealias DeleteCompletion = (DeleteResult) -> Void
    public func delete(completion: @escaping DeleteCompletion) {
        self.item = nil
        completion(.success(()))
    }
}
