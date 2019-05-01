//
//  PresetsCollectionViewFlowLayout.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

protocol PresetsCollectionViewFlowLayoutDelegate: class {
    func numberOfColumns() -> Int
    func columnSpacing() -> CGFloat
    func rowSpacing() -> CGFloat
    func collectionView(_ collectionView: UICollectionView, heightForRow: Int) -> CGFloat
    func insets() -> UIEdgeInsets
}

class PresetsCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var contentBounds = CGRect.zero
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    weak var delegate: PresetsCollectionViewFlowLayoutDelegate?
    
    var numberOfColumns: Int {
        return self.delegate?.numberOfColumns() ?? 1
    }
    
    var columnSpacing: CGFloat {
        return self.delegate?.columnSpacing() ?? 0.0
    }
    
    var rowSpacing: CGFloat {
        return self.delegate?.rowSpacing() ?? 0.0
    }
    
    var insets: UIEdgeInsets {
        return self.delegate?.insets() ?? .zero
    }
    
    var collectionViewCount: Int {
        return self.collectionView?.numberOfItems(inSection: 0) ?? 1
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        var currentIndex = 0
        var indexPath = IndexPath(row: currentIndex, section: 0)
        
        var currentRow = 0
        var currentColumn = 0
        
        var isEndRow: Bool {
            return currentRow == 0
        }
        var isEndColumn: Bool {
            return currentColumn == 0 || currentColumn == numberOfColumns - 1
        }
        
        let maxContentWidth = contentBounds.width
        var currentX = insets.left
        var currentY = insets.top
        
        let cellWidth = ((maxContentWidth - insets.left - insets.right) - (CGFloat(numberOfColumns - 1) * columnSpacing)) / CGFloat(numberOfColumns)
        
        while currentIndex < collectionViewCount {
            indexPath = IndexPath(row: currentIndex, section: 0)
//            var cellHeight = self.delegate?.collectionView(collectionView, heightForRow: currentRow) ?? 1.0
            let numberOfRows = collectionViewCount / numberOfColumns + (collectionViewCount % numberOfColumns == 0 ? 0 : 1)
            let cellHeight = ((contentBounds.height - insets.top - insets.bottom) - (rowSpacing * CGFloat(numberOfRows - 1))) / CGFloat(numberOfRows)
            if currentX + cellWidth + insets.right > maxContentWidth {
                currentRow += 1
//                cellHeight = self.delegate?.collectionView(collectionView, heightForRow: currentRow) ?? 1.0
                currentY += rowSpacing + cellHeight
                currentX = insets.left
            }
            let segmentFrame = CGRect(x: currentX, y: currentY, width: cellWidth, height: cellHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = segmentFrame
            cachedAttributes.append(attributes)
            currentColumn += 1
            currentIndex += 1
            currentX += cellWidth + columnSpacing
        }
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        var contentHeight = self.insets.top
        for row in 0...self.collectionViewCount / self.numberOfColumns {
            contentHeight += self.delegate?.collectionView(collectionView, heightForRow: row) ?? 0.0
            contentHeight += self.rowSpacing
        }
        contentHeight += self.insets.bottom
        return CGSize(width: contentBounds.width, height: contentBounds.height)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in self.cachedAttributes {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
}
