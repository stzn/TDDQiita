//
//  QiitaLoader.swift
//  QiitaFeature
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

public protocol QiitaLoader {
    typealias Result = Swift.Result<[QiitaItem], Error>
    typealias Completion = (Result) -> Void
    func load(completion: @escaping Completion)
    func refresh(completion: @escaping Completion)
}
