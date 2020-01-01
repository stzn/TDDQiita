//
//  PaginationQiitaLoader.swift
//  QiitaFeature
//
//  Created by Shinzan Takata on 2020/01/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

public protocol PaginationQiitaLoader {
    typealias Result = Swift.Result<[QiitaItem], Error>
    typealias Completion = (Result) -> Void

    func loadNext(completion: @escaping Completion)
    func refresh(completion: @escaping Completion)
}

