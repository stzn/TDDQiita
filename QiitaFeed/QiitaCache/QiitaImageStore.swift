//
//  QiitaImageStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

public protocol QiitaImageStore {
    typealias GetResult = Result<CachedQiitaImage?, Error>
    typealias GetCompletion = (GetResult) -> Void
    func get(for url: URL, completion: @escaping GetCompletion)

    typealias GetAllResult = Result<[CachedQiitaImage], Error>
    typealias GetAllCompletion = (GetAllResult) -> Void
    func getAll(completion: @escaping GetAllCompletion)

    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void
    func save(for url: URL, image: CachedQiitaImage, completion: @escaping SaveCompletion)

    typealias DeleteResult = Result<Void, Error>
    typealias DeleteCompletion = (DeleteResult) -> Void
    func delete(for url: URL, completion: @escaping DeleteCompletion)

    typealias DeleteAllResult = Result<Void, Error>
    typealias DeleteAllCompletion = (DeleteAllResult) -> Void
    func deleteAll(completion: @escaping DeleteAllCompletion)
}
