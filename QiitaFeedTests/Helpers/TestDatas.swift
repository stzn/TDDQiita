//
//  Helpers.swift
//  QiitaFeedTests
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature
@testable import QiitaFeed

var anyURL: URL {
    URL(string: "https://anyURL\(UUID().uuidString).com")!
}

var anyHTTPURLResponse: HTTPURLResponse {
    HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
}

var anyData: Data {
    Data(UUID().uuidString.utf8)
}

var anyNSError: NSError {
    NSError(domain: UUID().uuidString, code: -1, userInfo: nil)
}

var anyHTTPClientError: HTTPClientError {
    .unknown(anyNSError)
}

var anyQiitaItem: QiitaItem {
    QiitaItem(
        id: UUID().uuidString,
        likesCount: 1, reactionsCount: 1, commentsCount: 1, title: "title",
        createdAt: Date(), updatedAt: Date(), url: anyURL,
        tags: [QiitaItem.Tag(name: "tag")], user: nil)
}

var anyCachedQiitaItem: CachedQiitaItem {
    CachedQiitaItem(items: [anyQiitaItem], timestamp: Date())
}
