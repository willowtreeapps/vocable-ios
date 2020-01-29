//
//  TextSelectionViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class TextSelectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    enum Section: Int, CaseIterable {
        case textField
        case categories
        
        var columns: Int {
            switch self {
            case .textField:
                return 4
            case .categories:
                return 5
            }
        }
        
//        var groupHeight: Int {
//
//        }
//        case categories
//        case presets
    }
    
    enum Item: Int, CaseIterable {
        case textField
        case send
        case undo
        case toggleKeyboard
        case category1
        case category2
        case category3
        case category4
        case moreCategories
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "TextFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextFieldCollectionViewCell")
        collectionView.register(UINib(nibName: "TrackingButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TrackingButtonCollectionViewCell")
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionKind = Section.allCases[sectionIndex]
                        
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)
            
            let groupHeight = NSCollectionLayoutDimension.fractionalHeight(0.125)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: sectionKind.columns)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            return section
        }
        return layout
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            
            switch Item.allCases[indexPath.row] {
            case .textField:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextFieldCollectionViewCell", for: indexPath) as! TextFieldCollectionViewCell
                return cell
            case .send:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: "speak", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            case .undo:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: "undo", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            case .toggleKeyboard:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: "keyboard", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            case .category1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: "I want...", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            case .category2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: "I am...", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            case .category3:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: "Will you...", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            case .category4:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: "Confirmations", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            case .moreCategories:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: "More Categories", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField, .send, .undo])
        snapshot.appendSections([.categories])
        snapshot.appendItems([.category1, .category2, .category3, .category4, .moreCategories])
            
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
}
