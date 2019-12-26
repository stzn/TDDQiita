//
//  QiitaLoader.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

enum QiitaLoaderError: Error {
    case requestError(HTTPClientError)
    case decodeError(Error)
}

protocol QiitaLoader {
    typealias Result = Swift.Result<[QiitaItem], QiitaLoaderError>
    func fetch(url: URL, completion: @escaping (Result) -> Void)
}
