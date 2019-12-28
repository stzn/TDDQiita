//
//  QiitaListImageViewModel.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import QiitaFeature

final class QiitaListImageViewModel<Image> {
    let item: DisplayQiitaItem
    var onLoad: ((Image) -> Void)?
    var onLoadingStateChange: (() -> Void)?

    private var task: QiitaImageLoaderTask?
    private let loader: QiitaImageLoader
    private let imageTransformer: (Data?) -> Image
    init(item: DisplayQiitaItem,
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
            guard self.task != nil else {
                self.onLoad?(self.imageTransformer(nil))
                return
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
