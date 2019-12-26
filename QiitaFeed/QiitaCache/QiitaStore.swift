//
//  QiitaStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/18.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

protocol QiitaStore {
    typealias GetResult = Result<CachedQiitaItem?, Error>
    typealias GetCompletion = (GetResult) -> Void
    func get(completion: @escaping GetCompletion)

    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void
    func save(_ item: CachedQiitaItem, completion: @escaping SaveCompletion)

    typealias DeleteResult = Result<Void, Error>
    typealias DeleteCompletion = (DeleteResult) -> Void
    func delete(completion: @escaping DeleteCompletion)
}

