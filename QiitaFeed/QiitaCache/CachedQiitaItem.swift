//
//  CachedQiitaItem.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/18.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

struct CachedQiitaItem: Equatable {
    public let items: [QiitaItem]
    public let timestamp: Date

    public init(items: [QiitaItem], timestamp: Date) {
        self.items = items
        self.timestamp = timestamp
    }
}
