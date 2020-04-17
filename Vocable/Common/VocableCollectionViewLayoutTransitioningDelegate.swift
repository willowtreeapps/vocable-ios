//
//  VocableCollectionViewLayoutTransitioningDelegate.swift
//  Vocable
//
//  Created by Chris Stroud on 4/17/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@objc protocol VocableCollectionViewLayoutTransitioningDelegate: UICollectionViewDelegate {
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       shouldTranslateEntranceAnimationForItemAt indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       shouldTranslateExitAnimationForItemAt indexPath: IndexPath) -> Bool
}
