//
//  LoadingIndicator.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/25.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

protocol LoadingIndicator {
    func startLoading()
    func stopLoading()
}

extension UIActivityIndicatorView: LoadingIndicator {
    func startLoading() {
        startAnimating()
    }

    func stopLoading() {
        stopAnimating()
    }
}

extension UIRefreshControl: LoadingIndicator {
    func startLoading() {
        beginRefreshing()
    }

    func stopLoading() {
        endRefreshing()
    }
}
