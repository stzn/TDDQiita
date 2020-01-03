//
//  InMemoryQiitaStore.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

public final class InMemoryQiitaStore {
    private(set) var item: CachedQiitaItem?
    private(set) var images: [URL: CachedQiitaImage]
    public init(item: CachedQiitaItem? = nil, images: [URL: CachedQiitaImage] = [:]) {
        self.item = item
        self.images = images
    }
}

extension InMemoryQiitaStore: QiitaStore {
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
}

extension InMemoryQiitaStore: QiitaImageStore {
    public func get(for url: URL, completion: @escaping (QiitaImageStore.GetResult) -> Void) {
        completion(.success(images[url]))
    }

    public func getAll(completion: @escaping (QiitaImageStore.GetAllResult) -> Void) {
        completion(.success(images.map { $0.value }))
    }

    public func save(for url: URL, image: CachedQiitaImage,
                     completion: @escaping (QiitaImageStore.SaveResult) -> Void) {
        images[url] = image
        completion(.success(()))
    }

    public func delete(for url: URL, completion: @escaping (QiitaImageStore.DeleteResult) -> Void) {
        images[url] = nil
        completion(.success(()))
    }

    public func deleteAll(completion: @escaping (QiitaImageStore.DeleteAllResult) -> Void) {
        images.removeAll()
        completion(.success(()))
    }
}
