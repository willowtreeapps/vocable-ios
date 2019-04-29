//
//  PresetsCollectionViewController.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

protocol PresetsCollectionViewControllerDelegate: class {
    func presetsCollectionViewController(_ presetsCollectionViewController: PresetsCollectionViewController, addWidget widget: TrackableWidget)
    func presetsCollectionViewController(_ presetsCollectionViewController: PresetsCollectionViewController, didGazeOn model: PresetModel)
}

struct PresetModel {
    let value: String
}

class PresetsCollectionViewController: UICollectionViewController {
    
    weak var presetsDelegate: PresetsCollectionViewControllerDelegate?
    
    struct Constants {
        static let numberOfColumns = 3
        static let columnSpacing = CGFloat(8.0)
        static let rowSpacing = CGFloat(8.0)
        static let rowHeight = CGFloat(140.0)
        static let insets = UIEdgeInsets(top: 24.0, left: 24.0, bottom: 24.0, right: 24.0)
    }
    
    var presets: [PresetModel] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .appBackgroundColor
        self.collectionView.registerClass(UICollectionViewCell.self)
        self.collectionView.registerNib(PresetsCollectionViewCell.self)
        self.collectionView.delegate = nil
        if let layout = self.collectionView.collectionViewLayout as? PresetsCollectionViewFlowLayout {
            layout.delegate = self
        }
        
        self.presets = [PresetModel(value: "Thank you"), PresetModel(value: "Fix my pillow"),
                        PresetModel(value: "I didn't mean to say that"), PresetModel(value: "I am in pain"),
                        PresetModel(value: "I want my glasses"), PresetModel(value: "Close the curtain"),
                        PresetModel(value: "I love you"), PresetModel(value: "I am hungry"),
                        PresetModel(value: "I am thirsty"), PresetModel(value: "Wash my face"),
                        PresetModel(value: "Swab my mouth"), PresetModel(value: "I want to be suctioned"),
                        PresetModel(value: "Don't leave"), PresetModel(value: "Come back later"),
                        PresetModel(value: "Turn off the light")]
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let preset = self.presets[indexPath.row]
        let cell = collectionView.dequeueCell(type: PresetsCollectionViewCell.self, for: indexPath)
        cell.configure(with: preset)
        cell.onGaze = { _ in
            self.presetsDelegate?.presetsCollectionViewController(self, didGazeOn: preset)
        }
        self.presetsDelegate?.presetsCollectionViewController(self, addWidget: cell)
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
