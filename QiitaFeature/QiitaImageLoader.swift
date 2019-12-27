//
//  QiitaImageLoader.swift
//  QiitaFeature
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

public enum QiitaImageLoaderError: Error {
    case notFound
}

public protocol QiitaImageLoaderTask {
    func cancel()
}

public protocol QiitaImageLoader {
    typealias Result = Swift.Result<Data?, Error>
    typealias Completion = (Result) -> Void
    func load(url: URL, completion: @escaping Completion) -> QiitaImageLoaderTask
}
