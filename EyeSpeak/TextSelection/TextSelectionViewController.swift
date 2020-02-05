//
//  TextSelectionViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation

class TextSelectionViewController: UICollectionViewController {
    
    enum Category: CustomStringConvertible {
        case category1
        case category2
        case category3
        case category4
        
        var description: String {
            switch self {
            case .category1:
                return "Basic Needs"
            case .category2:
                return "Salutations"
            case .category3:
                return "Temperature"
            case .category4:
                return "Body"
            }
        }
    }
    
    private var categoryPresets: [Category: [ItemWrapper]] = [
        .category1: [.presetItem("I want the door closed."),
                .presetItem("I want the door open."),
                .presetItem("I would like to go to the bathroom."),
                .presetItem("I want the lights off."),
                .presetItem("I want the lights on."),
                .presetItem("I want my pillow fixed."),
                .presetItem("I would like some water."),
                .presetItem("I would like some coffee."),
                .presetItem("I want another pillow.")],
        .category2: [.presetItem("Hello"),
                .presetItem("How are you?"),
                .presetItem("Bye"),
                .presetItem("Goodbye"),
                .presetItem("Okay"),
                .presetItem("How's it going?"),
                .presetItem("Good"),
                .presetItem("How is your day?"),
                .presetItem("Bad")],
        .category3: [.presetItem("I am cold"),
                .presetItem("I am hot"),
                .presetItem("I want more blankets"),
                .presetItem("I want less blankets"),
                .presetItem("I feel fine"),
                .presetItem("I am sweating"),
                .presetItem("I am freezing"),
                .presetItem("I need a towel"),
                .presetItem("I need a jacket")],
        .category4: [.presetItem("Head"),
                .presetItem("Feet"),
                .presetItem("Hands"),
                .presetItem("Neck"),
                .presetItem("Arm"),
                .presetItem("Knee"),
                .presetItem("Side"),
                .presetItem("Right"),
                .presetItem("Left")]
    ]
    
    private let maxItemsPerPage = 9
    
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
    
    // TODO: Need to figure out how to update fractional width of cells without using collection view size
    private let totalHeight: CGFloat = 834.0
    private let totalWidth: CGFloat = 1112.0
    
    private var selectedCategory: Category = .category1 {
        didSet {
            self.updateSnapshot()
        }
    }
    private var currentSpeechText: String = "Select something below to speak" {
        didSet {
            self.updateSnapshot()
        }
    }
    
    enum Section: Int, CaseIterable {
        case topBar
        case textField
        case categories
        case presets
    }
    
    enum ItemWrapper: Hashable {
        case textField(String)
        case redo(String)
        case toggleKeyboard(String)
        case category(Category)
        case presetItem(String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        configureDataSource()
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "TextFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextFieldCollectionViewCell")
        collectionView.register(UINib(nibName: "TrackingButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TrackingButtonCollectionViewCell")
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = UIColor.collectionViewBackgroundColor
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
        
        configureDataSource()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = PresetUICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionKind = Section.allCases[sectionIndex]
            
            switch sectionKind {
            case .topBar:
                return self.topBarSectionLayout()
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
    
    private func topBarSectionLayout() -> NSCollectionLayoutSection {
        let redoButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(116.0 / 240.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let keyboardButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(116.0 / 240.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [redoButtonItem, keyboardButtonItem]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(64.0 / totalHeight)),
            subitems: subitems)
        containerGroup.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 256, bottom: 0, trailing: 256)
        
        return section
    }
    
    private func textFieldSectionLayout() -> NSCollectionLayoutSection {
        let textFieldItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [textFieldItem]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(86.0 / totalHeight)),
            subitems: subitems)
        containerGroup.interItemSpacing = .flexible(0)
        containerGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(400), top: .fixed(0), trailing: .flexible(400), bottom: .fixed(0))
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 0, trailing: 32)
        
        return section
    }
    
    private func categoriesSectionLayout() -> NSCollectionLayoutSection {
        let category1Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(262.0 / 1048.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let category2Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(262.0 / 1048.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let category3Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(262.0 / 1048.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let category4Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(262.0 / 1048.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [category1Item, category2Item, category3Item, category4Item]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(137.0 / totalHeight)),
            subitems: subitems)
        
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        footer.extendsBoundary = true
        footer.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [footer]
        
        return section
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (_: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .textField(let title):
                return self.setupCell(reuseIdentifier: TrackingButtonCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: title,
                                      titleColor: .defaultFontColor, textStyle: .largeTitle, backgroundColor: .clear,
                                      animationViewColor: .backspaceBloom, borderColor: .clear)
            case .redo(let title), .toggleKeyboard(let title):
                return self.setupCell(reuseIdentifier: TrackingButtonCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: title,
                                      titleColor: .defaultFontColor, textStyle: .footnote, backgroundColor: .defaultCellBackgroundColor,
                                      animationViewColor: .backspaceBloom, borderColor: .clear)
            case .category(let category):
                return self.setupCell(reuseIdentifier: TrackingButtonCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: category.description,
                                      titleColor: .defaultFontColor, textStyle: .footnote, backgroundColor: .categoryBackgroundColor,
                                      animationViewColor: .backspaceBloom, borderColor: .clear)
            case .presetItem(let preset):
                return self.setupCell(reuseIdentifier: TrackingButtonCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: preset,
                                      titleColor: .defaultFontColor, textStyle: .headline, backgroundColor: .defaultCellBackgroundColor,
                                      animationViewColor: .black, borderColor: .clear)
            }
        })
        
        updateSnapshot()
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        
        snapshot.appendSections([.topBar])
        snapshot.appendItems([.redo("redo"), .toggleKeyboard("keyboard")])
        
        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField(currentSpeechText)])
        
        snapshot.appendSections([.categories])
        snapshot.appendItems([.category(.category1), .category(.category2), .category(.category3), .category(.category4)])
    
        snapshot.appendSections([.presets])
        snapshot.appendItems(categoryPresets[selectedCategory]!)
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PresetPageControlView", for: indexPath) as! PresetPageControlReusableView
            self?.pageControl = view.pageControl
            return view
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
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

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        for selectedPath in collectionView.indexPathsForSelectedItems ?? [] {
            if selectedPath.section == indexPath.section && selectedPath != indexPath {
                collectionView.deselectItem(at: selectedPath, animated: true)
            }
        }
        
        switch selectedItem {
        case .presetItem(let text):
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synthesizer = AVSpeechSynthesizer.shared
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
            synthesizer.speak(utterance)
            currentSpeechText = text
        case .category(let category):
            selectedCategory = category
            return
        default:
            break
        }
        
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
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
    
    private func setupCell(reuseIdentifier: String, indexPath: IndexPath, title: String, titleColor: UIColor, textStyle: UIFont.TextStyle, backgroundColor: UIColor, animationViewColor: UIColor, borderColor: UIColor) -> TrackingButtonCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrackingButtonCollectionViewCell
        cell.setup(title: title, titleColor: titleColor, textStyle: textStyle, backgroundColor: backgroundColor, animationViewColor: animationViewColor, borderColor: borderColor)
        return cell
    }
    
}
