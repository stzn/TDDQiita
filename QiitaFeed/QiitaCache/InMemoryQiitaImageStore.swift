//
//  InMemoryQiitaImageStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

final class InMemoryQiitaImageStore: QiitaImageStore {
    typealias CachedImage = [URL: CachedQiitaImage]

    var cachedImage: CachedImage = [:]

    func get(for url: URL, completion: @escaping GetCompletion) {
        let cached = cachedImage[url]
        completion(.success(cached))
    }

    func save(url: URL, image: CachedQiitaImage, completion: @escaping SaveCompletion) {
        cachedImage[url] = image
        completion(.success(()))
    }

    func delete(url: URL, completion: @escaping DeleteCompletion) {
        cachedImage[url] = nil
        completion(.success(()))
    }
}
