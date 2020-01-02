//
//  LocalQiitaLoader.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2020/01/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

public final class LocalQiitaLoader {
    private(set) var shouldLoadNext: Bool = false
    private var cache: CachedQiitaItem?
    private var currentPage: Int = 1

    let store: QiitaStore
    let currentDate: () -> Date
    let perPageItemsCount: Int
    public init(store: QiitaStore,
                perPageItemsCount: Int,
                currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.perPageItemsCount = perPageItemsCount
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

extension LocalQiitaLoader: PaginationQiitaLoader {
    public func loadNext(completion: @escaping Completion) {
        if let items = getCachedItemsIfExist() {
            setNext(items)
            completion(.success(items))
            return
        }
        get(completion: completion)
    }

    func getCachedItemsIfExist() -> [QiitaItem]? {
        guard let cache = cache else {
            return nil
        }
        guard QiitaCachePolicy.validate(cache.timestamp, against: currentDate()) else {
            self.cache = nil
            return nil
        }
        return splitCacheItemsForResponse(cache.items)
    }

    private func splitCacheItemsForResponse(_ items: [QiitaItem]) -> [QiitaItem] {
        if items.count <= perPageItemsCount {
            return items
        }
        return Array(
            items.suffix(from: currentPage * perPageItemsCount - 1)
                .prefix(perPageItemsCount))
    }

    public func refresh(completion: @escaping Completion) {
        currentPage = 1
        self.cache = nil
        get(completion: completion)
    }

    private func get(completion: @escaping Completion) {
        store.get { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let cache):
                let result = self.handleResult(cache: cache)
                completion(result)
            }
        }
    }

    private func handleResult(cache: CachedQiitaItem?) -> PaginationQiitaLoader.Result {
        guard let cache = cache else {
            return .success([])
        }
        guard QiitaCachePolicy.validate(cache.timestamp, against: currentDate()) else {
            return .success([])
        }
        self.cache = cache
        let responseItems = splitCacheItemsForResponse(cache.items)
        setNext(responseItems)
        return .success(responseItems)
    }

    private func setNext(_ items: [QiitaItem]) {
        shouldLoadNext = items.count >= perPageItemsCount
        if shouldLoadNext {
            currentPage += 1
        }
    }
}

extension LocalQiitaLoader: QiitaCache {
    public func save(_ item: CachedQiitaItem, completion: @escaping SaveCompletion) {
        store.save(item, completion: completion)
    }

    public func delete(completion: @escaping DeleteCompletion) {
        store.delete(completion: completion)
    }
}
