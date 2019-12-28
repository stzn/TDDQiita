//
//  QiitaListImageViewModel.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

import QiitaFeature

final class QiitaListImageViewModel<Image> {
    private var task: QiitaImageLoaderTask?
    private let loader: QiitaImageLoader
    private let imageTransformer: (Data?) -> Image
    init(loader: QiitaImageLoader, imageTransformer: @escaping (Data?) -> Image) {
        self.loader = loader
        self.imageTransformer = imageTransformer
    }

    func load(from url: URL, completion: @escaping (Image) -> Void) {
        task = loader.load(url: url) { [weak self] result in
            guard let self = self else {
                return
            }
            guard self.task != nil else {
                completion(self.imageTransformer(nil))
                return
            }
            switch result {
            case .success(let .some(data)):
                completion(self.imageTransformer(data))
            case .success, .failure:
                completion(self.imageTransformer(nil))
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
