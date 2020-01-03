//
//  QiitaListCell+.swift
//  QiitaFeediOSTests
//
//  Created by shinzan_takata on 2019/12/25.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation
@testable import QiitaFeediOS

extension QiitaListCell {
    var title: String? {
        titleLabel.text
    }

    var userName: String? {
        userNameLabel.text
    }

    var likeCount: String? {
        likeCountLabel.text
    }

    var commentCount: String? {
        commentCountLabel.text
    }

    var updatedAt: String? {
        updatedAtLabel.text
    }

    var isLoadingIndicatorShowing: Bool {
        !indicator.isHidden
    }

    var userImage: Data? {
        userImageView.image?.pngData()
    }
}
