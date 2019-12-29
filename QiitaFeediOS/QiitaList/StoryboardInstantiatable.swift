//
//  StoryboardInstantiatable.swift
//  QiitaFeediOS
//
//  Created by shinzan_takata on 2019/12/25.
//  Copyright © 2019 shiz. All rights reserved.
//

import UIKit

public protocol StoryboardInstantiatable {
    static func instantiate() -> Self
}

extension StoryboardInstantiatable where Self: UIViewController {
    public static func instantiate() -> Self {
        let viewControllerName = String(describing: Self.self)
        return UIStoryboard(name: viewControllerName,
                            bundle: Bundle(for: Self.self))
            .instantiateViewController(identifier: viewControllerName) as Self
    }
}

