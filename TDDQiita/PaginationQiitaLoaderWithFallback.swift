//
//  PaginationQiitaLoaderWithFallback.swift
//  TDDQiita
//
//  Created by Shinzan Takata on 2020/01/03.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

final class PaginationQiitaLoaderWithFallback: PaginationQiitaLoader {
    private let primary: PaginationQiitaLoader
    private let fallback: PaginationQiitaLoader
    init(primary: PaginationQiitaLoader, fallback: PaginationQiitaLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func loadNext(completion: @escaping Completion) {
        primary.loadNext { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.loadNext(completion: completion)
            }
        }
    }

    func refresh(completion: @escaping Completion) {
        primary.refresh { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.refresh(completion: completion)
            }
        }
    }
}
