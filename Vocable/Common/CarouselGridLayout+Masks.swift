//
//  CarouselGridLayout+Masks.swift
//  Vocable
//
//  Created by Chris Stroud on 4/17/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct CellSeparatorMask: OptionSet {
    let rawValue: Int

    static let top = CellSeparatorMask(rawValue: 1 << 0)
    static let bottom = CellSeparatorMask(rawValue: 1 << 1)
    static let both: CellSeparatorMask = [.top, .bottom]
}

struct CellOrdinalButtonMask: OptionSet {
    let rawValue: Int

    static let topUpArrow = CellOrdinalButtonMask(rawValue: 1 << 0)
    static let bottomDownArrow = CellOrdinalButtonMask(rawValue: 1 << 1)
    static let both: CellOrdinalButtonMask = [.topUpArrow, .bottomDownArrow]
    static let none: CellOrdinalButtonMask = []
}

extension CarouselGridLayout {

    func separatorMask(for indexPath: IndexPath) -> CellSeparatorMask {
        let index = indexPath.item
        let rowIndexWithinPage = Int((index % itemsPerPage) / numberOfColumns)

        if rowIndexWithinPage == 0 {
            return .both
        } else {
            return .bottom
        }
    }
}
