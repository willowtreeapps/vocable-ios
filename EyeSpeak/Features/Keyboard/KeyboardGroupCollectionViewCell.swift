//
//  KeyboardKeyGroupCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class KeyboardGroupCollectionViewCell: VocableCollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    private var characters: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    func setup(title: String) {
        guard !title.isEmpty else {
            return
        }
        
        characters = title.map { "\($0)" }
        
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        characters = []
    }
    
    override func updateContentViews() {
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = .defaultCellBackgroundColor
//        borderedView.fillColor = isSelected ? .cellSelectionColor : fillColor
        borderedView.isOpaque = true
    }
    
    func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.backgroundColor = .defaultCellBackgroundColor
        self.collectionView.delaysContentTouches = false
        self.collectionView.isScrollEnabled = false
        
        collectionView.register(UINib(nibName: KeyboardKeyCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let letterItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(characters.count)), heightDimension: .fractionalHeight(1.0))
        let letterItem = NSCollectionLayoutItem(layoutSize: letterItemSize)
        
        let letterGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let letterGroup = NSCollectionLayoutGroup.horizontal(layoutSize: letterGroupSize, subitem: letterItem, count: characters.count)
        
        let section = NSCollectionLayoutSection(group: letterGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardKeyCollectionViewCell
        
        cell.setup(title: characters[indexPath.item])
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        characters.count
    }
    
}
