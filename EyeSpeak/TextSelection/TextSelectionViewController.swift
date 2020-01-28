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
        
        var columns: Int {
            switch self {
            case .textField:
                return 4
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
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupHeight = NSCollectionLayoutDimension.fractionalHeight(0.125)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: sectionKind.columns)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            return section
        }
        return layout
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            
            switch Section.allCases[indexPath.section] {
            case .textField:
                switch Item.allCases[indexPath.row] {
                case .textField:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextFieldCollectionViewCell", for: indexPath) as! TextFieldCollectionViewCell
                    return cell
                case .send:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                    cell.setup(title: "Send", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                    return cell
                case .undo:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                    cell.setup(title: "Undo", backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                    return cell
                case .toggleKeyboard:
                    fatalError("not implemented yet")
                }
                
//            case .categories:
//                break
//            case .presets:
//                break
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        Section.allCases.forEach { section in
            snapshot.appendSections([section])
            
            switch section {
            case .textField:
                snapshot.appendItems([.textField, .send, .undo])
            }
            
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}
