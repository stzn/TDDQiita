//
//  QiitaImageLoader.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

enum QiitaImageLoaderError: Error {
    case requestError(HTTPClientError)
}

protocol QiitaImageLoader {
    typealias Result = Swift.Result<Data, QiitaImageLoaderError>
    func fetch(url: URL, completion: @escaping (Result) -> Void)
}
