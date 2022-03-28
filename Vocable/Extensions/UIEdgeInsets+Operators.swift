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

    static func uniform(_ inset: CGFloat) -> UIEdgeInsets {
        .init(top: inset, left: inset, bottom: inset, right: inset)
    }

    static func vertical(_ verticalInset: CGFloat) -> UIEdgeInsets {
        .init(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
    }

    static func horizontal(_ horizontalInset: CGFloat) -> UIEdgeInsets {
        .init(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
    }
}
