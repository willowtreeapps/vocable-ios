//
//  TextSelectionViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class TextSelectionViewController: UICollectionViewController {
    
//    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Category {
        case want
        case need
        case three
        case confirmation
    }
    
    private var categoryPresets: [Category : [ItemWrapper]] = [
        .want: [.presetItem("I want the door closed."),
                .presetItem("I want the door open."),
                .presetItem("I would like to go to the bathroom."),
                .presetItem("I want the lights off."),
                .presetItem("I want the lights on."),
                .presetItem("I want my pillow fixed."),
                .presetItem("I would like some water."),
                .presetItem("I would like some coffee."),
                .presetItem("I want another pillow."),
        .presetItem("I want the door closed.2"),
        .presetItem("I want the door open.2"),
        .presetItem("I would like to go to the bathroom.2"),
        .presetItem("I want the lights off.2"),
        .presetItem("I want the lights on.2"),
        .presetItem("I want my pillow fixed.2"),
        .presetItem("I would like some water.2"),
        .presetItem("I would like some coffee.2"),
        .presetItem("I want the door closed.3"),
        .presetItem("I want the door open.3"),
        .presetItem("I would like to go to the bathroom.3"),
        .presetItem("I want the lights off.3"),
        .presetItem("I want the lights on.3"),
        .presetItem("I want my pillow fixed.3"),
        .presetItem("I want another pillow.3")],
        .need: (1...9).map { .presetItem("Need \($0)") },
        .three: (1...9).map { .presetItem("Three \($0)") },
        .confirmation: (1...9).map { .presetItem("Yes \($0)") },
    ]
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    private weak var orthogonalScrollView: UIScrollView? {
        didSet {
            scrollOffsetObserver = orthogonalScrollView?.observe(\.contentOffset, changeHandler: handleScrollViewOffsetChange(scrollView:offset:))
        }
    }
    private var scrollOffsetObserver: NSKeyValueObservation?
    private weak var pageControl: UIPageControl? {
        didSet {
            pageControl?.addTarget(self, action: #selector(handlePageControlChange), for: .valueChanged)
        }
    }
    
    private let totalHeight: CGFloat = 834.0
    private let totalWidth: CGFloat = 1112.0
    
    enum Section: Int, CaseIterable {
        case textField
        case categories
        case presets
    }
    
    enum ItemWrapper: Hashable {
        case textField
        case send(String)
        case undo(String)
        case toggleKeyboard(String)
        case category1(String)
        case category2(String)
        case category3(String)
        case category4(String)
        case moreCategories(String)
        case presetItem(String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "TextFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextFieldCollectionViewCell")
        collectionView.register(UINib(nibName: "TrackingButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TrackingButtonCollectionViewCell")
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = .black
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
        
        configureDataSource()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionKind = Section.allCases[sectionIndex]
            
            switch sectionKind {
            case .textField:
                return self.textFieldSectionLayout()
            case .categories:
                return self.categoriesSectionLayout()
            case .presets:
                return self.presetsSectionLayout()
            }
        }
        return layout
    }
    
    private func textFieldSectionLayout() -> NSCollectionLayoutSection {
        // TODO: implemnet edge insets and spacing like the categories section layout
        let textFieldItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(488.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let speakButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(168.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let undoButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(168.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let keyboardButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(176.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [textFieldItem, speakButtonItem, undoButtonItem, keyboardButtonItem]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(120.0 / totalHeight)),
            subitems: subitems)
        containerGroup.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
//        containerGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(24), top: .fixed(36), trailing: .flexible(24), bottom: .fixed(16))
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 0, trailing: 32)
        
        return section
    }
    
    private func categoriesSectionLayout() -> NSCollectionLayoutSection {
        let category1Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(170.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let category2Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(170.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let category3Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(170.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let category4Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(170.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let moreCategories = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(304.0 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        
        
        let subitems = [category1Item, category2Item, category3Item, category4Item, moreCategories]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(120.0 / totalHeight)),
            subitems: subitems)
        containerGroup.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        
        return section
    }
    
    private func presetsSectionLayout() -> NSCollectionLayoutSection {
        let presetItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(339.0 / totalWidth),
                                                                                   heightDimension: .fractionalHeight(1.0)))
        
        let rowGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1.0)),
            subitem: presetItem, count: 3)
        rowGroup.interItemSpacing = .fixed(16)
        
        let containerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(464.0 / totalHeight)),
            subitem: rowGroup, count: 3)
        containerGroup.interItemSpacing = .fixed(16)
        containerGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32)
        
        
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 64)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        footer.extendsBoundary = true
        footer.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [footer]
        
        return section
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .textField:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextFieldCollectionViewCell", for: indexPath) as! TextFieldCollectionViewCell
                return cell
            case .send(let title), .undo(let title), .toggleKeyboard(let title), .category1(let title), .category2(let title), .category3(let title), .category4(let title), .moreCategories(let title):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: title, titleColor: .white, textStyle: .footnote, backgroundColor: .black, animationViewColor: .backspaceBloom, borderColor: .white)
                return cell
            case .presetItem(let preset):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: preset, titleColor: UIColor(red:0.22, green:0.22, blue:0.22, alpha:1.0), textStyle: .headline, backgroundColor: .white, animationViewColor: .black, borderColor: .clear)
                return cell
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()

        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField, .send("speak"), .undo("undo"), .toggleKeyboard("keyboard")])
        snapshot.appendSections([.categories])
        snapshot.appendItems([.category1("Basic Needs"), .category2("Personal Care"), .category3("Salutations"), .category4("Yes | No"), .moreCategories("More Categories")])
        
        snapshot.appendSections([.presets])
        snapshot.appendItems(categoryPresets[.want]!)
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PresetPageControlView", for: indexPath) as! PresetPageControlReusableView
            self?.pageControl = view.pageControl
            return view
        }
            
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        func locateNearestContainingScrollView(for view: UIView?) -> UIScrollView? {
            if view == nil {
                return nil
            } else if let view = view as? UIScrollView {
                return view
            }
            return locateNearestContainingScrollView(for: view?.superview)
        }
        
        if  orthogonalScrollView == nil && dataSource.snapshot().indexOfSection(.presets) == indexPath.section {
            orthogonalScrollView = locateNearestContainingScrollView(for: cell)
        }
        
    }
    
    func handleScrollViewOffsetChange(scrollView: UIScrollView, offset: NSKeyValueObservedChange<CGPoint>) {
        let numPages = ceil(scrollView.contentSize.width / scrollView.bounds.width)
        let pageNum = floor(scrollView.bounds.midX / scrollView.bounds.width)
        
        if let pageControl = pageControl {
            pageControl.numberOfPages = Int(numPages)
            pageControl.currentPage = Int(pageNum)
        }
    }
    
    @objc func handlePageControlChange() {
        guard let page = pageControl?.currentPage, let scrollView = orthogonalScrollView else { return }
        let x = min(scrollView.bounds.width * CGFloat(page), scrollView.contentSize.width - scrollView.bounds.width)
        let rect = CGRect(x: x, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        orthogonalScrollView?.scrollRectToVisible(rect, animated: true)
    }
    
    
}
