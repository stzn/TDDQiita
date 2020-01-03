//
//  UITableView+Dequeueing.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/25.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
