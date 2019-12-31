//
//  QiitaJSONDecoder.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import QiitaFeature

public protocol QiitaJSONDecoder {
    static func decode(from data: Data) throws -> [QiitaItem]
}
