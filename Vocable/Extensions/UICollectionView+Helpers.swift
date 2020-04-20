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
}
