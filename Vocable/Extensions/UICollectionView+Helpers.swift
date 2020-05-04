//
//  UICollectionView+Helpers.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func indexPath(containing view: UIView) -> IndexPath? {
        for cell in self.visibleCells where view.isDescendant(of: cell) {
            if let indexPath = self.indexPath(for: cell) {
                return indexPath
            }
        }
        return nil
    }

    func indexPath(nearestTo indexPath: IndexPath) -> IndexPath? {
        return self.indexPath(before: indexPath) ?? self.indexPath(after: indexPath)
    }

    func indexPath(after indexPath: IndexPath) -> IndexPath? {
        let itemsInSection = numberOfItems(inSection: indexPath.section)
        let candidateIndex = indexPath.item + 1
        if candidateIndex >= itemsInSection {
            return nil
        } else {
            return IndexPath(row: candidateIndex, section: 0)
        }
    }

    func indexPath(before indexPath: IndexPath) -> IndexPath? {
        let candidateIndex = indexPath.item - 1
        if candidateIndex < 0 {
            return nil
        } else {
            return IndexPath(row: candidateIndex, section: 0)
        }
    }
}
