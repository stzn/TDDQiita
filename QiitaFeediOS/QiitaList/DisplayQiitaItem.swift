//
//  DisplayQiitaItem.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

public struct DisplayQiitaItem: Hashable {
    let title: String
    let userName: String
    let likesCount: String
    let commentsCount: String
    let updatedAt: String
    let userImageURL: URL?
    
    public init(
        title: String,
        userName: String,
        likesCount: String,
        commentsCount: String,
        updatedAt: String,
        userImageURL: URL?
    ) {
        self.title = title
        self.userName = userName
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.updatedAt = updatedAt
        self.userImageURL = userImageURL
    }
}
