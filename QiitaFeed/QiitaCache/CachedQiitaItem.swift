//
//  CachedQiitaItem.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/18.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

struct CachedQiitaItem: Equatable {
    let items: [QiitaItem]
    let timestamp: Date
}
