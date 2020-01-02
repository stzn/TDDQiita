//
//  QiitaListImageViewModel.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import QiitaFeature

public final class QiitaListImageViewModel<Image> {
    let item: DisplayQiitaItem
    var onLoad: ((Image) -> Void)?
    var onLoadingStateChange: (() -> Void)?

    private var task: QiitaImageLoaderTask?
    private let loader: QiitaImageLoader
    private let imageTransformer: (Data?) -> Image
    public init(item: DisplayQiitaItem,
         loader: QiitaImageLoader,
         imageTransformer: @escaping (Data?) -> Image) {
        self.item = item
        self.loader = loader
        self.imageTransformer = imageTransformer
    }

    func load() {
        guard let url = item.userImageURL else {
            onLoad?(imageTransformer(nil))
            return
        }

        onLoadingStateChange?()
        task = loader.load(url: url) { [weak self] result in
            guard let self = self else {
                return
            }
            defer {
                self.onLoadingStateChange?()
            }
            let data = try? result.get()
            self.onLoad?(self.imageTransformer(data))
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
