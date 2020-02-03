//
//  UICollectionView+Gaze.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

extension UICollectionView {

    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        return self
    }

    private func selectItem(for gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        let point = gaze.location(in: self)
        guard let indexPath = indexPathForItem(at: point) else {
            for path in indexPathsForSelectedItems ?? [] {
                deselectItem(at: path, animated: true )
            }
            return
        }
        if !(indexPathsForSelectedItems ?? []).contains(indexPath) {
            selectItem(at: indexPath, animated: true, scrollPosition: .init())
        }
    }

    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        selectItem(for: gaze, with: event)
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        selectItem(for: gaze, with: event)
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        for path in indexPathsForSelectedItems ?? [] {
            deselectItem(at: path, animated: true)
        }
    }
}
