//
//  QiitaCacheDecorator.swift
//  TDDQiita
//
//  Created by Shinzan Takata on 2020/01/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation
import QiitaFeature
import QiitaFeed

final class QiitaCacheDecorator: PaginationQiitaLoader {
    private let decoratee: PaginationQiitaLoader
    private let cache: QiitaCache
    init(decoratee: PaginationQiitaLoader, cache: QiitaCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func loadNext(completion: @escaping Completion) {
        decoratee.loadNext { [weak self] result in
            completion(result.map { items in
                self?.cache.save(
                    CachedQiitaItem(items: items, timestamp: Date()), completion: { _ in }
                )
                return items
            })
        }
    }

    func refresh(completion: @escaping Completion) {
        decoratee.refresh { [weak self] result in
            completion(result.map { items in
                self?.cache.save(
                    CachedQiitaItem(items: items, timestamp: Date()), completion: { _ in }
                )
                return items
            })
        }
    }
}
