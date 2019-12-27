//
//  QiitaListViewModel.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import QiitaFeature

final class QiitaListViewModel {
    var onLoadStateChange: (() -> Void)?
    var onRefreshStateChange: (() -> Void)?

    private let loader: QiitaLoader
    var onLoad: (([QiitaItem]) -> Void)!
    var onError: ((Error) -> Void)!
    init(loader: QiitaLoader) {
        self.loader = loader
    }

    func load() {
        onLoadStateChange?()
        loader.load { [weak self] result in
            self?.handleResult(result: result)
            self?.onLoadStateChange?()
        }
    }

    func refresh() {
        onRefreshStateChange?()
        loader.load { [weak self] result in
            self?.handleResult(result: result)
            self?.onRefreshStateChange?()
        }
    }

    private func handleResult(result: QiitaLoader.Result) {
        switch result {
        case .success(let items):
            onLoad(items)
        case .failure(let error):
            onError(error)
        }
    }
}
