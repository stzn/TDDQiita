//
//  InMemoryQiitaImageStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

public final class InMemoryQiitaImageStore: QiitaImageStore {
    typealias CachedImage = [URL: CachedQiitaImage]

    public init() {}

    var cachedImage: CachedImage = [:]

    public func get(for url: URL, completion: @escaping GetCompletion) {
        let cached = cachedImage[url]
        completion(.success(cached))
    }

    public func save(for url: URL, image: CachedQiitaImage, completion: @escaping SaveCompletion) {
        cachedImage[url] = image
        completion(.success(()))
    }

    public func delete(for url: URL, completion: @escaping DeleteCompletion) {
        cachedImage[url] = nil
        completion(.success(()))
    }
}
