//
//  QiitaListViewModel.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeed

final class QiitaListViewModel {
    private let loader: QiitaLoader
    init(loader: QiitaLoader) {
        self.loader = loader
    }

    func load(completion: @escaping (Result<[QiitaItem], Error>) -> Void) {
        loader.load(completion: completion)
    }
}
