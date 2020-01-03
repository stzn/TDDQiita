//
//  QiitaListViewModel.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import QiitaFeature

public final class QiitaListViewModel {
    public var onLoadStateChange: (() -> Void)?
    public var onRefreshStateChange: (() -> Void)?
    public var onLoad: (([QiitaItem]) -> Void)?
    public var onError: ((Error) -> Void)?

    private let loader: PaginationQiitaLoader
    public init(loader: PaginationQiitaLoader) {
        self.loader = loader
    }

    func load() {
        onLoadStateChange?()
        loader.loadNext { [weak self] result in
            self?.handleResult(result: result)
            self?.onLoadStateChange?()
        }
    }

    func refresh() {
        onRefreshStateChange?()
        loader.refresh { [weak self] result in
            self?.handleResult(result: result)
            self?.onRefreshStateChange?()
        }
    }

    private func handleResult(result: QiitaLoader.Result) {
        switch result {
        case .success(let items):
            onLoad?(items)
        case .failure(let error):
            onError?(error)
        }
    }
}
