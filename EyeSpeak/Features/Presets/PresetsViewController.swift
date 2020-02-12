//
//  TextSelectionViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation

class PresetsViewController: UICollectionViewController {
    
    private lazy var categoryPresets: [PresetCategory: [ItemWrapper]] = {
        TextPresets.presetsByCategory.mapValues { $0.map { .presetItem($0) } }
    }()
    
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
    
    private var selectedCategory: PresetCategory = .category1 {
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
        case keyboard
    }
    
    enum ItemWrapper: Hashable {
        case textField(String)
        case topBarButton(TopBarButton)
        case category(PresetCategory)
        case presetItem(String)
        case keyGroup(KeyGroup)
    }
    
    enum TopBarButton: String {
        case repeatSpokenText
        case toggleKeyboard
        
        var image: UIImage? {
            switch self {
            case .repeatSpokenText:
                return UIImage(systemName: "repeat")
            case .toggleKeyboard:
                return UIImage(systemName: "keyboard")
            default:
                return nil
            }
        }
    }
    
    private var showKeyboard: Bool = false {
        didSet {
            self.updateSnapshot()
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        configureDataSource()
        
        collectionView.selectItem(at: dataSource.indexPath(for: .category(.category1)), animated: false, scrollPosition: .init())
    }
    
    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        collectionView.register(UINib(nibName: "TextFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextFieldCollectionViewCell")
        collectionView.register(UINib(nibName: "CategoryItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryItemCollectionViewCell")
        collectionView.register(UINib(nibName: "PresetItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PresetItemCollectionViewCell")
        collectionView.register(UINib(nibName: "KeyboardKeyGroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KeyboardKeyGroupCollectionViewCell")
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
        layout.register(CategorySectionBackground.self, forDecorationViewOfKind: "CategorySectionBackground")
        collectionView.backgroundColor = UIColor.collectionViewBackgroundColor
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = PresetUICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionKind = Section.allCases[sectionIndex]
            
            switch sectionKind {
            case .topBar:
                return PresetUICollectionViewCompositionalLayout.topBarSectionLayout()
            case .textField:
                return PresetUICollectionViewCompositionalLayout.textFieldSectionLayout()
            case .categories:
                return PresetUICollectionViewCompositionalLayout.categoriesSectionLayout()
            case .presets:
                guard !self.showKeyboard else {
                    return nil
                }
                
                return PresetUICollectionViewCompositionalLayout.presetsSectionLayout()
            case .keyboard:
                return PresetUICollectionViewCompositionalLayout.keyboardSectionLayout()
            }
        }
        return layout
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (_: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .textField(let title):
                return self.setupCell(reuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: title, fillColor: .collectionViewBackgroundColor)
            case .topBarButton(let buttonType):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
                cell.setup(with: buttonType.image)
                return cell
            case .category(let category):
                return self.setupCell(reuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: category.description)
            case .presetItem(let preset):
                return self.setupCell(reuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: preset)
            case .keyGroup(let keyGroup):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "KeyboardKeyGroupCollectionViewCell", for: indexPath) as! KeyboardKeyGroupCollectionViewCell
                cell.setup(title: keyGroup.containedCharacters)
                return cell
            }
        })
        
        updateSnapshot()
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        
        snapshot.appendSections([.topBar])
        
        if AppConfig.showIncompleteFeatures {
            snapshot.appendItems([.topBarButton(.repeatSpokenText), .topBarButton(.toggleKeyboard)])
        }
        
        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField(currentSpeechText)])
        
        snapshot.appendSections([.categories])
        snapshot.appendItems([.category(.category1), .category(.category2), .category(.category3), .category(.category4)])
    
        snapshot.appendSections([.presets])
        
        if !showKeyboard {
            snapshot.appendItems(categoryPresets[selectedCategory]!)
        }
        
        snapshot.appendSections([.keyboard])
        
        if showKeyboard {
            snapshot.appendItems(KeyGroup.QWERTYKeyboardGroups.map { .keyGroup($0) })
            
            // FIXME: use a real item type here
            snapshot.appendItems([.keyGroup(KeyGroup("space")),
                                  .keyGroup(KeyGroup("Speak"))])
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if kind == "CategorySectionBackground" {
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CategorySectionBackground", for: indexPath) as! CategorySectionBackground
                return view
            }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PresetPageControlView", for: indexPath) as! PresetPageControlReusableView
            self?.pageControl = view.pageControl
            return view
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Collection View Delegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField:
            return false
        case .category, .presetItem, .topBarButton, .keyGroup:
            return true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField:
            return false
        case .category, .presetItem, .topBarButton, .keyGroup:
            return true
        }
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
        case .topBarButton(let buttonType):
            switch buttonType {
            case .repeatSpokenText:
                AVSpeechSynthesizer.shared.speak(currentSpeechText)
            case .toggleKeyboard:
                showKeyboard.toggle()
            }
        case .presetItem(let text):
            currentSpeechText = text
            AVSpeechSynthesizer.shared.speak(currentSpeechText)
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
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .presetItem, .topBarButton:
            return true
        case .category, .textField, .keyGroup:
            return false
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
    
    private func setupCell(reuseIdentifier: String, indexPath: IndexPath, title: String, fillColor: UIColor = .defaultCellBackgroundColor) -> PresetItemCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
        
        cell.setup(title: title)
        cell.fillColor = fillColor
        
        return cell
    }
    
}
