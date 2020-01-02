//
//  QiitaImageCacheDecorator.swift
//  TDDQiita
//
//  Created by Shinzan Takata on 2020/01/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation
import QiitaFeature
import QiitaFeed

final class QiitaImageCacheDecorator: QiitaImageLoader {
    private let decoratee: QiitaImageLoader
    private let cache: QiitaImageCache
    init(decoratee: QiitaImageLoader, cache: QiitaImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func load(url: URL, completion: @escaping Completion) -> QiitaImageLoaderTask {
        decoratee.load(url: url) { [weak self] result in
            completion(result.map { data in
                if let data = data {
                    self?.cache.save(for: url, data: data, completion: { _ in })
                }
                return data
            })
        }
    }
}
