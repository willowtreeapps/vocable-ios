//
//  AutoLayout.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

/// Auto Layout DSL to simplify common layout operations

public enum Anchor: Hashable {
    case left, right, top, bottom, centerX, centerY
}

public enum LayoutRelation {
    case equal, greaterThanOrEqual, lessThanOrEqual
}

protocol Constrainable {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }

    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }

    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }

    func prepareForLayout()
}

private extension Constrainable {
    func xLayoutAnchor(for anchor: Anchor) -> NSLayoutXAxisAnchor? {
        switch anchor {
        case .left:     return leadingAnchor
        case .right:    return trailingAnchor
        case .centerX:  return centerXAnchor
        default:        return nil
        }
    }

    func yLayoutAnchor(for anchor: Anchor) -> NSLayoutYAxisAnchor? {
        switch anchor {
        case .top:      return topAnchor
        case .bottom:   return bottomAnchor
        case .centerY:  return centerYAnchor
        default:        return nil
        }
    }
}

extension UIView: Constrainable {
    func prepareForLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UILayoutGuide: Constrainable {
    func prepareForLayout() {}
}

extension Constrainable {

    // MARK: - Width and Height

    @discardableResult
    public func constrain(width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
        prepareForLayout()
        let constraints = [
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    public func constrain(width: NSLayoutDimension, height: NSLayoutDimension) -> [NSLayoutConstraint] {
        prepareForLayout()
        let constraints = [
            widthAnchor.constraint(equalTo: width, multiplier: 1.0),
            heightAnchor.constraint(equalTo: height, multiplier: 1.0)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    public func constrain(width: NSLayoutDimension, height: NSLayoutDimension, constant: CGFloat) -> [NSLayoutConstraint] {
        prepareForLayout()
        let constraints = [
            widthAnchor.constraint(equalTo: width, multiplier: 1.0, constant: constant),
            heightAnchor.constraint(equalTo: height, multiplier: 1.0, constant: constant)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    public func constrain(width: CGFloat, layoutRelation: LayoutRelation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        prepareForLayout()

        let constraint: NSLayoutConstraint
        switch layoutRelation {
        case .equal:
            constraint = widthAnchor.constraint(equalToConstant: width)
        case .greaterThanOrEqual:
            constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: width)
        case .lessThanOrEqual:
            constraint = widthAnchor.constraint(lessThanOrEqualToConstant: width)
        }

        constraint.priority = priority

        NSLayoutConstraint.activate([
            constraint
        ])
        return constraint
    }

    @discardableResult
    public func constrain(
        toWidthOf other: Constrainable,
        scaledBy scale: CGFloat = 1,
        offsetBy offset: CGFloat = 0,
        priority: UILayoutPriority = .required,
        layoutRelation: LayoutRelation = .equal
    ) -> NSLayoutConstraint {
        prepareForLayout()

        let constraint: NSLayoutConstraint

        switch layoutRelation {
        case .equal:
            constraint = widthAnchor.constraint(
                equalTo: other.widthAnchor,
                multiplier: scale
            )
        case .greaterThanOrEqual:
            constraint = widthAnchor.constraint(
                greaterThanOrEqualTo: other.widthAnchor,
                multiplier: scale
            )
        case .lessThanOrEqual:
            constraint = widthAnchor.constraint(
                lessThanOrEqualTo: other.widthAnchor,
                multiplier: scale
            )
        }

        constraint.constant = offset
        constraint.priority = priority

        NSLayoutConstraint.activate([constraint])

        return constraint
    }

    @discardableResult
    public func constrain(aspectRatio: CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        prepareForLayout()
        let constraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1 / aspectRatio)
        constraint.priority = priority
        NSLayoutConstraint.activate([
            constraint
        ])
        return constraint
    }

    @discardableResult
    public func constrain(height: CGFloat, layoutRelation: LayoutRelation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        prepareForLayout()

        let constraint: NSLayoutConstraint
        switch layoutRelation {
        case .equal:
            constraint = heightAnchor.constraint(equalToConstant: height)
        case .greaterThanOrEqual:
            constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        case .lessThanOrEqual:
            constraint = heightAnchor.constraint(lessThanOrEqualToConstant: height)
        }

        constraint.priority = priority

        NSLayoutConstraint.activate([constraint])
        return constraint
    }

    @discardableResult
    public func constrain(
        toHeightOf other: Constrainable,
        scaledBy scale: CGFloat = 1,
        offsetBy offset: CGFloat = 0,
        priority: UILayoutPriority = .required,
        layoutRelation: LayoutRelation = .equal
    ) -> NSLayoutConstraint {
        prepareForLayout()

        let constraint: NSLayoutConstraint

        switch layoutRelation {
        case .equal:
            constraint = heightAnchor.constraint(
                equalTo: other.heightAnchor,
                multiplier: scale
            )
        case .greaterThanOrEqual:
            constraint = heightAnchor.constraint(
                greaterThanOrEqualTo: other.heightAnchor,
                multiplier: scale
            )
        case .lessThanOrEqual:
            constraint = heightAnchor.constraint(
                lessThanOrEqualTo: other.heightAnchor,
                multiplier: scale
            )
        }

        constraint.constant = offset
        constraint.priority = priority

        NSLayoutConstraint.activate([constraint])

        return constraint
    }

    // MARK: - Anchors

    @discardableResult
    public func constrain(
        _ anchor: Anchor,
        to receiverAnchor: Anchor,
        of other: Constrainable,
        constant: CGFloat = 0,
        layoutRelation: LayoutRelation = .equal,
        priority: UILayoutPriority = .required,
        safely: Bool = false
    ) -> [NSLayoutConstraint] {
        prepareForLayout()
        var constraints: [NSLayoutConstraint] = []

        switch anchor {
        case .left, .right, .centerX:
            guard
                let sourceLayoutAnchor = layoutAnchorX(anchor, of: self),
                let destinationLayoutAnchor = layoutAnchorX(receiverAnchor, of: other, safely: safely) else {
                    return constraints
            }

            var constraint: NSLayoutConstraint

            switch layoutRelation {
            case .equal:
                constraint = sourceLayoutAnchor.constraint(equalTo: destinationLayoutAnchor, constant: constant)
                constraints.append(constraint)
            case .greaterThanOrEqual:
                constraint = sourceLayoutAnchor.constraint(greaterThanOrEqualTo: destinationLayoutAnchor, constant: constant)
                constraints.append(constraint)
            case .lessThanOrEqual:
                constraint = sourceLayoutAnchor.constraint(lessThanOrEqualTo: destinationLayoutAnchor, constant: constant)
                constraints.append(constraint)
            }

            constraint.priority = priority
        case .top, .bottom, .centerY:
            guard
                let sourceLayoutAnchor = layoutAnchorY(anchor, of: self),
                let destinationAnchor = layoutAnchorY(receiverAnchor, of: other, safely: safely) else {
                    return constraints
            }

            var constraint: NSLayoutConstraint

            switch layoutRelation {
            case .equal:
                constraint = sourceLayoutAnchor.constraint(equalTo: destinationAnchor, constant: constant)
                constraints.append(constraint)
            case .greaterThanOrEqual:
                constraint = sourceLayoutAnchor.constraint(greaterThanOrEqualTo: destinationAnchor, constant: constant)
                constraints.append(constraint)
            case .lessThanOrEqual:
                constraint = sourceLayoutAnchor.constraint(lessThanOrEqualTo: destinationAnchor, constant: constant)
                constraints.append(constraint)
            }

            constraint.priority = priority
        }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    // MARK: - Convenience

    @discardableResult
    public func constrain(
        fill other: Constrainable,
        excluding excludedSides: Set<Anchor> = [],
        insets: UIEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        if !excludedSides.contains(.top) {
            constraints.append(contentsOf: constrain(.top, to: .top, of: other, constant: insets.top))
        }

        if !excludedSides.contains(.left) {
            constraints.append(contentsOf: constrain(.left, to: .left, of: other, constant: insets.left))
        }

        if !excludedSides.contains(.bottom) {
            constraints.append(contentsOf: constrain(.bottom, to: .bottom, of: other, constant: -insets.bottom))
        }

        if !excludedSides.contains(.right) {
            constraints.append(contentsOf: constrain(.right, to: .right, of: other, constant: -insets.right))
        }

        return constraints
    }

    @discardableResult
    func constrainToSafeArea(of parentView: UIView, withPadding padding: CGFloat = 0) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    public func constrain(fill other: Constrainable, constant: CGFloat) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: constrain(.left, to: .left, of: other, constant: constant))
        constraints.append(contentsOf: constrain(.right, to: .right, of: other, constant: -constant))
        constraints.append(contentsOf: constrain(.top, to: .top, of: other, constant: constant))
        constraints.append(contentsOf: constrain(.bottom, to: .bottom, of: other, constant: -constant))
        return constraints
    }

    @discardableResult
    public func constrain(fill other: Constrainable, insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: constrain(.left, to: .left, of: other, constant: insets.left))
        constraints.append(contentsOf: constrain(.right, to: .right, of: other, constant: -insets.right))
        constraints.append(contentsOf: constrain(.top, to: .top, of: other, constant: insets.top))
        constraints.append(contentsOf: constrain(.bottom, to: .bottom, of: other, constant: -insets.bottom))
        return constraints
    }

    @discardableResult
    public func constrain(centerIn other: Constrainable) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(contentsOf: constrain(.centerX, to: .centerX, of: other))
        constraints.append(contentsOf: constrain(.centerY, to: .centerY, of: other))
        return constraints
    }

    @discardableResult
    public func constrain(
        centerHorizontallyIn other: Constrainable,
        offsetBy offset: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        constrain(.centerX, to: .centerX, of: other, constant: offset)
    }

    @discardableResult
    public func constrain(
        centerVerticallyIn other: Constrainable,
        offsetBy offset: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        constrain(.centerY, to: .centerY, of: other, constant: offset)
    }

    // MARK: - Private Helpers

    private func layoutAnchorX(_ anchor: Anchor, of constrainable: Constrainable, safely: Bool = false) -> NSLayoutXAxisAnchor? {
        guard let view = constrainable as? UIView else { return constrainable.xLayoutAnchor(for: anchor) }

        let layoutItem: Constrainable = (safely ? view.safeAreaLayoutGuide : view)
        return layoutItem.xLayoutAnchor(for: anchor)
    }

    private func layoutAnchorY(_ anchor: Anchor, of constrainable: Constrainable, safely: Bool = false) -> NSLayoutYAxisAnchor? {
        guard let view = constrainable as? UIView else { return constrainable.yLayoutAnchor(for: anchor) }

        let layoutItem: Constrainable = (safely ? view.safeAreaLayoutGuide : view)
        return layoutItem.yLayoutAnchor(for: anchor)
    }
}
