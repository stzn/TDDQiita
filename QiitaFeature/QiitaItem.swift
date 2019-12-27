//
//  QiitaItem.swift
//  QiitaFeature
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

public struct QiitaItem: Codable, Equatable, Hashable {
    public init(id: String, likesCount: Int,
                reactionsCount: Int, commentsCount: Int,
                title: String, createdAt: Date, updatedAt: Date,
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

    public static func ==(lhs: QiitaItem, rhs: QiitaItem) -> Bool {
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

    public let id: String
    public let likesCount: Int
    public let reactionsCount: Int
    public let commentsCount: Int
    public let title: String
    public let createdAt: Date
    public let updatedAt: Date
    public let url: URL
    public let tags: [Tag]
    public let user: User?

    public var userImageURL: URL? {
        user?.userImageURL
    }

    public struct Tag: Codable, Equatable, Hashable {
        public init(name: String) {
            self.name = name
        }

        public static func ==(lhs: QiitaItem.Tag, rhs: QiitaItem.Tag) -> Bool {
            return lhs.name == rhs.name
        }

        public let name: String
    }

    public struct User: Codable, Equatable, Hashable {
        public init(githubLoginName: String?,
                    profileImageUrl: String?) {
            self.githubLoginName = githubLoginName
            self.profileImageUrl = profileImageUrl
        }

        public static func ==(lhs: QiitaItem.User, rhs: QiitaItem.User) -> Bool {
            return lhs.githubLoginName == rhs.githubLoginName
                && lhs.profileImageUrl == rhs.profileImageUrl
        }

        public let githubLoginName: String?
        public let profileImageUrl: String?

        public var userImageURL: URL? {
            URL(string: profileImageUrl ?? "")
        }
    }
}

