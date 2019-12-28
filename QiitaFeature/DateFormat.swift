//
//  DateFormat.swift
//  QiitaFeature
//
//  Created by Shinzan Takata on 2019/12/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

public enum DateFormat: String {
    case defaultFormat = "yyyy-MM-dd HH:mm:ss"
    case ISO8601Format = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    case japaneseFormat = "yyyy年MM月dd日HH時mm分"
}

public let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = NSTimeZone.system
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .gregorian)
    return formatter
}()

public extension Date {
    func string(format: DateFormat = .defaultFormat) -> String {
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }

    init?(dateString: String, dateFormat: DateFormat = .defaultFormat) {
        formatter.dateFormat = dateFormat.rawValue
        guard let date = formatter.date(from: dateString) else { return nil }
        self = date
    }

    init?(fromISO8601: String) {
        guard let date = Date(dateString: fromISO8601, dateFormat: .ISO8601Format) else { return nil }
        self = date
    }
}

public extension String {
    func fromISO8601String(dateFormat: DateFormat) -> String? {
        guard let date = Date(fromISO8601: self) else { return nil }
        return date.string(format: dateFormat)
    }
}
