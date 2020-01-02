//
//  QiitaImageLoaderWithFallback.swift
//  TDDQiita
//
//  Created by Shinzan Takata on 2020/01/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

final class QiitaImageLoaderWithFallback: QiitaImageLoader {
    private let primary: QiitaImageLoader
    private let fallback: QiitaImageLoader
    init(primary: QiitaImageLoader, fallback: QiitaImageLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    private class Task: QiitaImageLoaderTask {
        var wrapped: QiitaImageLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }

    func load(url: URL, completion: @escaping Completion) -> QiitaImageLoaderTask {
        let task = Task()
        task.wrapped = primary.load(url: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallback.load(url: url, completion: completion)
            }
        }
        return task
    }
}
