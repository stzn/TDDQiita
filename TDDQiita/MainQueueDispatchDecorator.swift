//
//  MainQueueDispatchDecorator.swift
//  QiitaFeediOS
//
//  Created by Shinzan Takata on 2019/12/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: PaginationQiitaLoader where T == PaginationQiitaLoader {
    func loadNext(completion: @escaping PaginationQiitaLoader.Completion) {
        decoratee.loadNext { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }

    func refresh(completion: @escaping PaginationQiitaLoader.Completion) {
        decoratee.refresh { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: QiitaImageLoader where T == QiitaImageLoader {
    func load(url: URL, completion: @escaping QiitaImageLoader.Completion) -> QiitaImageLoaderTask {
        return decoratee.load(url: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
