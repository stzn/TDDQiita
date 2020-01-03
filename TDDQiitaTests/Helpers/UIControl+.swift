//
//  UIControl+.swift
//  QiitaFeediOSTests
//
//  Created by Shinzan Takata on 2019/12/22.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?
                .forEach { (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
