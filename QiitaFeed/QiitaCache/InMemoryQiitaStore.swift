//
//  InMemoryQiitaStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

public final class InMemoryQiitaStore: QiitaStore, QiitaImageStore {
    public init() {}

    private(set) var item: CachedQiitaItem? = nil
    private(set) var images: [URL: CachedQiitaImage] = [:]

    public func get(completion: @escaping (QiitaStore.GetResult) -> Void) {
        completion(.success(item))
    }

    public func save(_ item: CachedQiitaItem, completion: @escaping (QiitaStore.SaveResult) -> Void) {
        self.item = item
        completion(.success(()))
    }

    public func delete(completion: @escaping (QiitaStore.DeleteResult) -> Void) {
        self.item = nil
        completion(.success(()))
    }

    public func get(for url: URL, completion: @escaping (QiitaImageStore.GetResult) -> Void) {
        completion(.success(images[url]))
    }

    public func save(for url: URL, image: CachedQiitaImage, completion: @escaping (QiitaImageStore.SaveResult) -> Void) {
        images[url] = image
        completion(.success(()))
    }

    public func delete(for url: URL, completion: @escaping (QiitaImageStore.DeleteResult) -> Void) {
        images[url] = nil
        completion(.success(()))
    }
}
