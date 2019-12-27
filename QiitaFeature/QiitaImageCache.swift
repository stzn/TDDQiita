//
//  QiitaImageCache.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/21.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

public protocol QiitaImageCache {
    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void
    typealias DeleteResult = Result<Void, Error>
    typealias DeleteCompletion = (DeleteResult) -> Void

    func save(for url: URL, data: Data, completion: @escaping SaveCompletion)
    func delete(for url: URL, completion: @escaping DeleteCompletion)
}
