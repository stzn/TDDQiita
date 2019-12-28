//
//  CodableQiitaItem.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/28.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

struct CodableQiitaItem: Codable {
    init(id: String, likesCount: Int,
                reactionsCount: Int, commentsCount: Int,
                title: String, createdAt: String, updatedAt: String,
                url: URL, tags: [Tag] , user: User?) {
        self.id = id
        self.likesCount = likesCount
        self.reactionsCount = reactionsCount
        self.commentsCount = commentsCount
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.url = url
        self.tags = tags
        self.user = user
    }

    static func ==(lhs: CodableQiitaItem, rhs: CodableQiitaItem) -> Bool {
        return lhs.id == rhs.id
            && lhs.likesCount == rhs.likesCount
            && lhs.reactionsCount == rhs.reactionsCount
            && lhs.commentsCount == rhs.commentsCount
            && lhs.title == rhs.title
            && lhs.createdAt == rhs.createdAt
            && lhs.updatedAt == rhs.updatedAt
            && lhs.url == rhs.url
            && lhs.tags == rhs.tags
            && lhs.user == rhs.user
    }

    let id: String
    let likesCount: Int
    let reactionsCount: Int
    let commentsCount: Int
    let title: String
    let createdAt: String
    let updatedAt: String
    let url: URL
    let tags: [Tag]
    let user: User?

    struct Tag: Codable, Equatable {
        init(name: String) {
            self.name = name
        }

        static func ==(lhs: CodableQiitaItem.Tag, rhs: CodableQiitaItem.Tag) -> Bool {
            return lhs.name == rhs.name
        }

        let name: String
    }

    struct User: Codable, Equatable, Hashable {
        init(githubLoginName: String?,
                    profileImageUrl: String?) {
            self.githubLoginName = githubLoginName
            self.profileImageUrl = profileImageUrl
        }

        static func ==(lhs: CodableQiitaItem.User, rhs: CodableQiitaItem.User) -> Bool {
            return lhs.githubLoginName == rhs.githubLoginName
                && lhs.profileImageUrl == rhs.profileImageUrl
        }

        let githubLoginName: String?
        let profileImageUrl: String?
    }
}

