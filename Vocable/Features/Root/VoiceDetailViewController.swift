//
//  VoiceDetailViewController.swift
//  Vocable
//
//  Created by Steve Foster on 12/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import CoreData

class VoiceResponseViewController: PagingCarouselViewController, NSFetchedResultsControllerDelegate {

    @PublishedValue private(set) var lastUtterance: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.all.subtracting(.top)
        view.layoutMargins.top = 4

        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
        collectionView.delaysContentTouches = false

//        updateLayoutForCurrentTraitCollection()

//        frc.delegate = self
//        try? frc.performFetch()
    }

}
