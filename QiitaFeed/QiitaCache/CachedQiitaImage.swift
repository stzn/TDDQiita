//
//  CachedQiitaImage.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/21.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

public struct CachedQiitaImage {
    public let data: Data
    public let timestamp: Date
    public init(data: Data, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
    }
}
