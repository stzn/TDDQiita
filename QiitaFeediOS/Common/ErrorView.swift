//
//  ErrorView.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/24.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

final class ErrorView: UIView {
    private var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemRed
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    var message: String? {
        get { isVisible ? label.text : nil }
        set { setMessageAnimated(newValue) }
    }

    private var isVisible: Bool {
        alpha > 0
    }

    private func setup() {
        label.text = nil
        alpha = 0
    }

    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            show(message)
        } else {
            hide()
        }
    }

    private func show(_ message: String) {
        label.text = message
        alpha = 1
    }

    private func hide() {
        label.text = nil
        alpha = 0
    }
}
