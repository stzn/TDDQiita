//
//  Date+.swift
//  QiitaFeedTests
//
//  Created by shinzan_takata on 2019/12/19.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

extension Date {
    func minusQiitaCacheMaxAge() -> Date {
        advanced(byDays: -cacheMaxAge)
    }

    private var cacheMaxAge: Int {
        return 7
    }

    func advanced(byDays: Int) -> Date {
        advanced(by: TimeInterval(60*60*24*byDays))
    }
}
