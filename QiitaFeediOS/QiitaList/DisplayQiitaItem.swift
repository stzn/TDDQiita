//
//  DisplayQiitaItem.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/27.
//  Copyright © 2019 shiz. All rights reserved.
//

struct DisplayQiitaItem: Hashable {
    let title: String
    let userName: String
    let likesCount: String
    let commentsCount: String
    let updatedAt: String
    let userImageURL: URL?
}
