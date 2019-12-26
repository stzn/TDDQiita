//
//  LocalQiitaImageLoader.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/20.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

final class LocalQiitaImageLoader {
    let store: QiitaImageStore
    let currentDate: () -> Date
    init(store: QiitaImageStore,
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

    @discardableResult
    func load(url: URL, completion: @escaping Completion) -> QiitaImageLoaderTask {
        let task = LocalQiitaImageLoaderTask(completion)
        store.get(for: url) { result in
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
    func save(for url: URL, data: Data, completion: @escaping SaveCompletion) {
        store.save(url: url,
                   image: CachedQiitaImage(data: data, timestamp: Date()),
                   completion: completion)
    }

    func delete(for url: URL, completion: @escaping DeleteCompletion) {
        store.delete(url: url, completion: completion)
    }
}
