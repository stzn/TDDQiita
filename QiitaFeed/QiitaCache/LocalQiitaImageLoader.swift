//
//  LocalQiitaImageLoader.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

public final class LocalQiitaImageLoader {
    private let store: QiitaImageStore
    private let currentDate: () -> Date
    public init(store: QiitaImageStore,
         currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalQiitaImageLoader: QiitaImageLoader {
    private class LocalQiitaImageLoaderTask: QiitaImageLoaderTask {
        var completion: Completion?
        init(_ completion: @escaping Completion) {
            self.completion = completion
        }

        func complete(with result: QiitaImageLoader.Result) {
            completion?(result)
        }

        func cancel() {
            completion = nil
        }
    }

    public func load(url: URL, completion: @escaping Completion) -> QiitaImageLoaderTask {
        let task = LocalQiitaImageLoaderTask(completion)
        store.get(for: url) { [weak self] result in
            guard self != nil else {
                return
            }
            switch result {
            case .success(let .some(cached)):
                task.complete(with: .success(cached.data))
            case .success:
                task.complete(with: .failure(QiitaImageLoaderError.notFound))
            case .failure(let error):
                task.complete(with: .failure(error))
            }
        }
        return task
    }
}

extension LocalQiitaImageLoader: QiitaImageCache {
    public func save(for url: URL, data: Data, completion: @escaping SaveCompletion) {
        store.save(for: url,
                   image: CachedQiitaImage(url: url, data: data, timestamp: Date()),
                   completion: completion)
    }

    public func delete(for url: URL, completion: @escaping DeleteCompletion) {
        store.delete(for: url, completion: completion)
    }
}
