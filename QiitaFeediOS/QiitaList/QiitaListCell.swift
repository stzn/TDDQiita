//
//  QiitaListCell.swift
//  TDDQiita
//
//  Created by Shinzan Takata on 2019/12/22.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

final class QiitaListCell: UITableViewCell {
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var userNameLabel: UILabel!
    @IBOutlet private(set) weak var likeCountLabel: UILabel!
    @IBOutlet private(set) weak var commentCountLabel: UILabel!
    @IBOutlet private(set) weak var updatedAtLabel: UILabel!
    @IBOutlet private(set) weak var indicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var userImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        resetUI()
    }

    func configure(_ item: DisplayQiitaItem) {
        resetUI()
        titleLabel.text = item.title
        userNameLabel.text = item.userName
        likeCountLabel.text = item.likesCount
        commentCountLabel.text = item.commentsCount
        updatedAtLabel.text = item.updatedAt
    }

    private func resetUI() {
        titleLabel.text = nil
        userNameLabel.text = nil
        likeCountLabel.text = nil
        commentCountLabel.text = nil
        updatedAtLabel.text = nil
        userImageView.image = nil
    }

    func startImageLoading() {
        indicator.startAnimating()
    }

    func stopImageLoading() {
        indicator.stopAnimating()
    }

    func setUserImage(from image: UIImage) {
        userImageView.image = image
    }
}
