//
//  QiitaListImageViewModel.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeed

final class QiitaListImageViewModel {
    private var task: QiitaImageLoaderTask?
    private let loader: QiitaImageLoader
    init(loader: QiitaImageLoader) {
        self.loader = loader
    }

    func load(from url: URL, completion: @escaping (Result<Data?, Error>) -> Void) {
        task = loader.load(url: url) { [weak self] result in
            guard self?.task != nil else {
                completion(.success(nil))
                return
            }
            completion(result)
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
