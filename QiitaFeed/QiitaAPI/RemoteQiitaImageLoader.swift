//
//  RemoteQiitaImageLoader.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

final class RemoteQiitaImageLoader: QiitaImageLoader {
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    private final class RemoteQiitaImageLoaderTask: QiitaImageLoaderTask {
        var task: HTTPClientTask?
        private var completion: Completion?

        init(_ completion: @escaping Completion) {
            self.completion = completion
        }

        func complete(with result: QiitaImageLoader.Result) {
            completion?(result)
        }

        func cancel() {
            completion = nil
            task?.cancel()
        }
    }

    @discardableResult
    func load(url: URL, completion: @escaping Completion) -> QiitaImageLoaderTask {
        let task = RemoteQiitaImageLoaderTask(completion)
        task.task = client.get(from: url) { result in
            switch result {
            case .success(let data, _):
                task.complete(with: .success(data))
            case .failure(let error):
                task.complete(with: .failure(error))
            }
        }
        return task
    }
}
