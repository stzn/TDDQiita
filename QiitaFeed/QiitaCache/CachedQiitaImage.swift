//
//  CachedQiitaImage.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/21.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

public struct CachedQiitaImage {
    public let url: URL
    public let data: Data
    public let timestamp: Date
    public init(url: URL, data: Data, timestamp: Date) {
        self.url = url
        self.data = data
        self.timestamp = timestamp
    }
}
