//
//  UICollectionView+Gaze.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

private class UICollectionViewGazeTarget: Equatable {

    let indexPath: IndexPath
    let beginDate: Date
    var isCancelled = false
    init(beginDate: Date, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.beginDate = beginDate
    }

    static func == (lhs: UICollectionViewGazeTarget, rhs: UICollectionViewGazeTarget) -> Bool {
        return lhs.indexPath == rhs.indexPath
    }
}

extension UICollectionView {
    
    override var canReceiveGaze: Bool {
        true
    }

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
        guard !isHidden else { return nil }
        for view in subviews.reversed() {
            let point = view.convert(point, from: self)
            if let result = view.gazeableHitTest(point, with: event) {
                return result
            }
        }
        if self.point(inside: point, with: event) && canReceiveGaze {
            return self
        }
        return nil
    }

    private func setItemHighlighted(_ highlighted: Bool, at indexPath: IndexPath) {
        if let cell = cellForItem(at: indexPath) {
            if highlighted {
                guard delegate?.collectionView?(self, shouldHighlightItemAt: indexPath) ?? true else {
                    return
                }
                
                cell.isHighlighted = true
                delegate?.collectionView?(self, didHighlightItemAt: indexPath)
            } else {
                cell.isHighlighted = false
                delegate?.collectionView?(self, didUnhighlightItemAt: indexPath)
            }
        }

        if !highlighted,
            indexPathIsSelected(indexPath),
            delegate?.collectionView?(self, shouldDeselectItemAt: indexPath) ?? true {
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
            if let oldTarget = gazeTarget, !oldTarget.isCancelled, !indexPathIsSelected(oldTarget.indexPath) {
                let timeElapsed = Date().timeIntervalSince(oldTarget.beginDate)
                if timeElapsed >= AppConfig.selectionHoldDuration {
                    guard delegate?.collectionView?(self, shouldSelectItemAt: oldTarget.indexPath) ?? true else {
                        return
                    }
                    (self.window as? HeadGazeWindow)?.animateCursorSelection()
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
        if let oldTarget = gazeTarget, !oldTarget.isCancelled {
            setItemHighlighted(false, at: oldTarget.indexPath)
            gazeTarget = nil
        }
    }

    override func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard let target = gazeTarget else { return }
        target.isCancelled = true
        setItemHighlighted(false, at: target.indexPath)
    }
}
