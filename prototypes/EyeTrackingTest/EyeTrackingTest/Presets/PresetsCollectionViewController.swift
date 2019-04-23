//
//  PresetsCollectionViewController.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PresetsCollectionViewController: UICollectionViewController {
    struct Constants {
        static let numberOfColumns = 3
        static let columnSpacing = CGFloat(8.0)
        static let rowSpacing = CGFloat(8.0)
        static let rowHeight = CGFloat(100.0)
        static let insets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
    
    var presets: [String] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.registerClass(UICollectionViewCell.self)
        self.collectionView.registerNib(PresetsCollectionViewCell.self)
        self.collectionView.delegate = nil
        if let layout = self.collectionView.collectionViewLayout as? PresetsCollectionViewFlowLayout {
            layout.delegate = self
        }
        
        var fakePresets: [String] = []
        for i in 1...20 {
            fakePresets.append("This is preset \(i)")
        }
        presets.append(contentsOf: fakePresets)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: PresetsCollectionViewCell.self, for: indexPath)
        cell.configure(with: presets[indexPath.row])
        return cell
    }
}

extension PresetsCollectionViewController: PresetsCollectionViewFlowLayoutDelegate {
    func numberOfColumns() -> Int {
        return Constants.numberOfColumns
    }
    
    func columnSpacing() -> CGFloat {
        return Constants.columnSpacing
    }
    
    func rowSpacing() -> CGFloat {
        return Constants.rowSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForRow: Int) -> CGFloat {
        return Constants.rowHeight
    }
    
    func insets() -> UIEdgeInsets {
        return Constants.insets
    }
}
