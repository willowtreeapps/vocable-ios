//
//  UICollectionView+Gaze.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

private class UICollectionViewGazeTarget: NSObject {
    let indexPath: IndexPath
    let beginDate: Date
    init(beginDate: Date, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.beginDate = beginDate
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? UICollectionViewGazeTarget else {
            return false
        }
        return indexPath == other.indexPath
    }
}

extension UICollectionView {

    private struct AssociatedKeys {
        static var gazeTarget: UInt8 = 0
    }

    var indexPathForGazedItem: IndexPath? {
        return gazeTarget?.indexPath
    }

    private var gazeTarget: UICollectionViewGazeTarget? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gazeTarget) as? UICollectionViewGazeTarget
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.gazeTarget, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        return self
    }

    private func setItemHighlighted(_ highlighted: Bool, at indexPath: IndexPath) {
        if let cell = cellForItem(at: indexPath) {
            if highlighted {
                cell.isHighlighted = true
                delegate?.collectionView?(self, didHighlightItemAt: indexPath)
            } else {
                cell.isHighlighted = false
                delegate?.collectionView?(self, didUnhighlightItemAt: indexPath)
            }
        }
        if !highlighted, indexPathIsSelected(indexPath)  {
            deselectItem(at: indexPath, animated: true)
            delegate?.collectionView?(self, didDeselectItemAt: indexPath)
        }
    }

    private func indexPathIsSelected(_ indexPath: IndexPath) -> Bool {
        return indexPathsForSelectedItems?.contains(indexPath) ?? false
    }

    private func updateGazeTarget(for gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        let newTarget = target(for: gaze, with: event)
        let oldTarget = gazeTarget
        if newTarget == oldTarget {

            // Update the existing target's selection state if needed
            if let oldTarget = oldTarget, !indexPathIsSelected(oldTarget.indexPath) {
                let timeElapsed = Date().timeIntervalSince(oldTarget.beginDate)
                if timeElapsed >= gaze.selectionHoldDuration {
                    selectItem(at: oldTarget.indexPath, animated: true, scrollPosition: .init())
                    delegate?.collectionView?(self, didSelectItemAt: oldTarget.indexPath)
                }
            }
            return
        }

        if let oldTarget = oldTarget {
            setItemHighlighted(false, at: oldTarget.indexPath)
            gazeTarget = nil
        }

        if let newTarget = newTarget {
            setItemHighlighted(true, at: newTarget.indexPath)
            gazeTarget = newTarget
        }
    }

    private func target(for gaze: UIHeadGaze, with event: UIHeadGazeEvent?) -> UICollectionViewGazeTarget? {
        let point = gaze.location(in: self)
        guard let indexPath = indexPathForItem(at: point) else {
            return nil
        }
        return UICollectionViewGazeTarget(beginDate: Date(), indexPath: indexPath)
    }

    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        updateGazeTarget(for: gaze, with: event)
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        updateGazeTarget(for: gaze, with: event)
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        if let oldTarget = gazeTarget {
            setItemHighlighted(false, at: oldTarget.indexPath)
            gazeTarget = nil
        }
    }
}
