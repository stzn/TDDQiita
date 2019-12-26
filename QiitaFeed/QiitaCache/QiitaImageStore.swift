//
//  QiitaImageStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

protocol QiitaImageStore {
    typealias GetResult = Result<CachedQiitaImage?, Error>
    typealias GetCompletion = (GetResult) -> Void
    func get(for url: URL, completion: @escaping GetCompletion)

    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void
    func save(url: URL, image: CachedQiitaImage, completion: @escaping SaveCompletion)

    typealias DeleteResult = Result<Void, Error>
    typealias DeleteCompletion = (DeleteResult) -> Void
    func delete(url: URL, completion: @escaping DeleteCompletion)
}
