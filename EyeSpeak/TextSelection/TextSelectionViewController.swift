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
        case basicNeeds
        case personalCare
        case salutations
        case yesNo
        
        var description: String {
            switch self {
            case .basicNeeds:
                return "Basic Needs"
            case .personalCare:
                return "Personal Care"
            case .salutations:
                return "Salutations"
            case .yesNo:
                return "Yes | No"
            }
        }
    }
    
    private var categoryPresets: [Category: [ItemWrapper]] = [
        .basicNeeds: [.presetItem("I want the door closed."),
                .presetItem("I want the door open."),
                .presetItem("I would like to go to the bathroom."),
                .presetItem("I want the lights off."),
                .presetItem("I want the lights on."),
                .presetItem("I want my pillow fixed."),
                .presetItem("I would like some water."),
                .presetItem("I would like some coffee."),
                .presetItem("I want another pillow.")],
        .personalCare: (1...28).map { .presetItem("Personal Care Item \($0)") },
        .salutations: (1...9).map { .presetItem("Salutation item \($0)") },
        .yesNo: (1...9).map { .presetItem("Yes | No item \($0)") }
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
    
    private var selectedCategory: Category = .basicNeeds {
        didSet {
            self.updateSnapshot()
        }
    }
    private var currentSpeechText: String = "" {
        didSet {
            self.updateSnapshot()
        }
    }
    
    enum Section: Int, CaseIterable {
        case textField
        case categories
        case presets
    }
    
    enum ItemWrapper: Hashable {
        case textField(String)
        case redo(String)
        case toggleKeyboard(String)
        case category(Category)
        case moreCategories(String)
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
        collectionView.backgroundColor = .black
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
        
        configureDataSource()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
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
        let textFieldItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth((846.0 + 16.0) / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let redoButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth((75.0 + 16.0) / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let keyboardButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth((108.0 + 16.0) / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [textFieldItem, redoButtonItem, keyboardButtonItem]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(120.0 / totalHeight)),
            subitems: subitems)
        containerGroup.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 0, trailing: 32)
        
        return section
    }
    
    private func categoriesSectionLayout() -> NSCollectionLayoutSection {
        let category1Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(182.8 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let category2Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(182.8 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let category3Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(182.8 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        let category4Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(182.8 / totalWidth),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let moreCategories = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(317.8 / totalWidth),
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
                return self.setupCell(reuseIdentifier: TrackingButtonCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: title, titleColor: .white,
                                      textStyle: .footnote, backgroundColor: .clear, animationViewColor: .backspaceBloom, borderColor: .clear)
            case .redo(let title), .toggleKeyboard(let title), .moreCategories(let title):
                return self.setupCell(reuseIdentifier: TrackingButtonCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: title, titleColor: .white,
                                      textStyle: .footnote, backgroundColor: .black, animationViewColor: .backspaceBloom, borderColor: .white)
            case .category(let category):
                return self.setupCell(reuseIdentifier: TrackingButtonCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: category.description, titleColor: .white,
                                      textStyle: .footnote, backgroundColor: .black, animationViewColor: .backspaceBloom, borderColor: .white)
            case .presetItem(let preset):
                return self.setupCell(reuseIdentifier: TrackingButtonCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: preset, titleColor: UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0),
                                      textStyle: .headline, backgroundColor: .white, animationViewColor: .black, borderColor: .clear)
            }
        })
        
        updateSnapshot()
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()

        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField(currentSpeechText), .redo("redo"), .toggleKeyboard("keyboard")])
        snapshot.appendSections([.categories])
        snapshot.appendItems([.category(.basicNeeds), .category(.personalCare), .category(.salutations), .category(.yesNo), .moreCategories("More Categories")])
        
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
        default:
            break
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
    
    private func setupCell(reuseIdentifier: String, indexPath: IndexPath, title: String, titleColor: UIColor, textStyle: UIFont.TextStyle, backgroundColor: UIColor, animationViewColor: UIColor, borderColor: UIColor) -> TrackingButtonCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrackingButtonCollectionViewCell
        cell.setup(title: title, titleColor: titleColor, textStyle: textStyle, backgroundColor: backgroundColor, animationViewColor: animationViewColor, borderColor: borderColor)
        return cell
    }
    
}
