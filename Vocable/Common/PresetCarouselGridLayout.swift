//
//  PresetCarouselGridLayout.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 4/16/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetCarouselGridLayout: CarouselGridLayout {
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) ?? self.layoutAttributesForItem(at: itemIndexPath)
        attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        return attr
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) ?? self.layoutAttributesForItem(at: itemIndexPath)
        attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        return attr
    }
}
