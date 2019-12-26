//
//  LocalQiitaLoader.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/18.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

final class LocalQiitaLoader {
    let store: QiitaStore
    let currentDate: () -> Date
    init(store: QiitaStore,
         currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }

    func validateCache() {
        store.get { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let .some(cached)) where QiitaCachePolicy.validate(cached.timestamp, against: self.currentDate()):
                break
            case .failure, .success:
                self.store.delete { _ in }
            }
        }
    }
}

extension LocalQiitaLoader: QiitaCache {
    func save(_ item: CachedQiitaItem, completion: @escaping SaveCompletion) {
        store.save(item, completion: completion)
    }

    func delete(completion: @escaping DeleteCompletion) {
        store.delete(completion: completion)
    }
}

extension LocalQiitaLoader: QiitaLoader {
    func load(completion: @escaping Completion) {
        store.get { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let .some(cached)) where QiitaCachePolicy.validate(cached.timestamp, against: self.currentDate()):
                completion(.success(cached.items))
            case .success:
                completion(.success([]))
            }
        }
    }
}
