//
//  TestDatas.swift
//  QiitaFeediOSTests
//
//  Created by shinzan_takata on 2019/12/23.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

var anyURL: URL {
    URL(string: "https://anyURL\(UUID().uuidString).com")!
}

var anyQiitaItem: QiitaItem {
    QiitaItem(
        id: UUID().uuidString,
        likesCount: 1, reactionsCount: 1, commentsCount: 1, title: "title",
        createdAt: Date(), updatedAt: Date(), url: anyURL,
        tags: [QiitaItem.Tag(name: "tag")], user: anyUser)
}

var anyUser: QiitaItem.User {
    QiitaItem.User(githubLoginName: UUID().uuidString,
                   profileImageUrl: anyURL.absoluteString)
}

var anyNSError: NSError {
    NSError(domain: UUID().uuidString, code: -1, userInfo: nil)
}
