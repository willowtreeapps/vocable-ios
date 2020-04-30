//
//  UITraitCollection+Helpers.swift
//  Vocable
//
//  Created by Chris Stroud on 4/29/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

// This is an experimental way to (hopefully?) make
// UITraitCollection more manageable to query against

struct SizeClass: OptionSet {

    typealias RawValue = Int

    let rawValue: RawValue
    static let hRegular = SizeClass(rawValue: 1 << 1)
    static let hCompact = SizeClass(rawValue: 1 << 2)
    static let vRegular = SizeClass(rawValue: 1 << 3)
    static let vCompact = SizeClass(rawValue: 1 << 4)

    static let hRegular_vRegular: SizeClass = [.hRegular, .vRegular]
    static let hRegular_vCompact: SizeClass = [.hRegular, .vCompact]
    static let hCompact_vRegular: SizeClass = [.hCompact, .vRegular]
    static let hCompact_vCompact: SizeClass = [.hCompact, .vCompact]

    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    init(_ traitCollection: UITraitCollection) {

        var result: SizeClass = []

        switch traitCollection.horizontalSizeClass {
        case .compact:
            result.insert(.hCompact)
        case .regular:
            result.insert(.hRegular)
        case .unspecified:
            result.insert([.hCompact, .hRegular])
        default:
            break
        }

        switch traitCollection.verticalSizeClass {
        case .compact:
            result.insert(.vCompact)
        case .regular:
            result.insert(.vRegular)
        case .unspecified:
            result.insert([.vCompact, .vRegular])
        default:
            break
        }

        self.init(rawValue: result.rawValue)
    }

    func contains(any genericClass: UIUserInterfaceSizeClass) -> Bool {
        switch genericClass {
        case .compact:
            return !self.isDisjoint(with: [.hCompact, .vCompact])
        case .regular:
            return !self.isDisjoint(with: [.hRegular, .vRegular])
        default:
            return true
        }
    }
}

protocol TraitCollectionProvider {

    var traitCollection: UITraitCollection { get }
}

extension TraitCollectionProvider {

    var sizeClass: SizeClass {
        return .init(traitCollection)
    }
}

extension UIView: TraitCollectionProvider { }
extension UIViewController: TraitCollectionProvider { }
