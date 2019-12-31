//
//  QiitaAPIDecoder.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/31.
//  Copyright © 2019 shiz. All rights reserved.
//

import QiitaFeature

public struct QiitaAPIDecoder {
    public static func decode(from data: Data) throws -> [QiitaItem] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let items = try decoder.decode([CodableQiitaItem].self, from: data)
        return convertToQiitaItems(from: items)
    }

    static func convertToQiitaItems(from codableItems: [CodableQiitaItem]) -> [QiitaItem] {
        codableItems.map { codable in
            var user: QiitaItem.User?
            if let codableUser = codable.user {
                user = QiitaItem.User(
                    githubLoginName: codableUser.githubLoginName,
                    profileImageUrl: codableUser.profileImageUrl)
            }
            return QiitaItem(id: codable.id,
                             likesCount: codable.likesCount,
                             reactionsCount: codable.reactionsCount,
                             commentsCount: codable.commentsCount,
                             title: codable.title,
                             createdAt: Date(fromISO8601: codable.createdAt)!,
                             updatedAt: Date(fromISO8601: codable.updatedAt)!,
                             url: codable.url,
                             tags: codable.tags.map { codable in QiitaItem.Tag(name: codable.name) },
                             user: user)
        }
    }
}
