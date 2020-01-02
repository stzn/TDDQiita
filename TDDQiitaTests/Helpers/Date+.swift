//
//  Date+.swift
//  TDDQiitaTests
//
//  Created by Shinzan Takata on 2020/01/03.
//  Copyright © 2020 shiz. All rights reserved.
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
