//
//  QiitaCachePolicy.swift
//  QiitaFeed
//
//  Created by shinzan_takata on 2019/12/18.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

final class QiitaCachePolicy {
    private init() {}
    static let maxAge: TimeInterval = 60*60*24*7
    static func validate(_ timestamp: Date, against: Date) -> Bool {
        return against.advanced(by: -maxAge) <= timestamp
    }
}
