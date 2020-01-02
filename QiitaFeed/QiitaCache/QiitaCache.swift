//
//  QiitaCache.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/21.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

public protocol QiitaCache {
    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void

    typealias DeleteResult = Result<Void, Error>
    typealias DeleteCompletion = (DeleteResult) -> Void

    func save(_ item: CachedQiitaItem, completion: @escaping SaveCompletion)
    func delete(completion: @escaping DeleteCompletion)
}
