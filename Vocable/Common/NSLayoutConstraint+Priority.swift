//
//  NSLayoutConstraint+Priority.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/17/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {

    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    func withPriority(_ rawPriority: Float) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(rawValue: rawPriority)
        return self
    }
}
