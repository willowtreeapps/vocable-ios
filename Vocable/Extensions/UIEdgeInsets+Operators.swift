//
//  UIEdgeInsets+Operators.swift
//  Vocable
//
//  Created by Chris Stroud on 2/26/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    init(uniform value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    static func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top + rhs.top,
                            left: lhs.left + rhs.left,
                            bottom: lhs.bottom + rhs.bottom,
                            right: lhs.right + rhs.right)
    }

    static func - (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top - rhs.top,
                            left: lhs.left - rhs.left,
                            bottom: lhs.bottom - rhs.bottom,
                            right: lhs.right - rhs.right)
    }
}
