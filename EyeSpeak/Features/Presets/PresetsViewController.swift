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
    
    private enum HintText: String, CaseIterable {
        case preset = "Select something below to speak"
        case keyboard = "Select letters below to start typing."
    }
    
    private var isShowingHintText: Bool {
        HintText.allCases.map({$0.rawValue}).contains(currentSpeechText)
    }
    
    private var currentSpeechText: String = HintText.preset.rawValue {
        didSet {
            self.updateSnapshot()
        }
    }
    
    let textExpression = TextExpression()
    
    enum Section: Int, CaseIterable {
        case topBar
        case textField
        case categories
        case predictiveText
        case presets
        case keyboard
    }
    
    enum ItemWrapper: Hashable {
        case textField(String)
        case topBarButton(TopBarButton)
        case category(PresetCategory)
        case predictiveText(TextPrediction)
        case presetItem(String)
        case key(String)
        case keyboardFunctionButton(KeyboardFunctionButton)
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
            }
        }
    }
    
    enum KeyboardFunctionButton {
        case clear
        case backspace
        case space
        case speak
        
        var image: UIImage {
            switch self {
            case .clear:
                return UIImage(systemName: "trash")!
            case .backspace:
                return UIImage(systemName: "arrow.left.circle")!
            case .space:
                return UIImage(systemName: "shift")!
            case .speak:
                return UIImage(systemName: "speaker.2.fill")!
            }
        }
    }
    
    private var showKeyboard: Bool = false {
        didSet {
            self.updateSnapshot()
        }
    }
    
    // TODO: Hook this up with the TextExpression predict() function when the user updates
    // the text in the text field
    let predictions: [TextPrediction] = []
    
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
        collectionView.register(UINib(nibName: "KeyboardKeyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KeyboardKeyCollectionViewCell")
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
        layout.register(CategorySectionBackground.self, forDecorationViewOfKind: "CategorySectionBackground")
        collectionView.backgroundColor = UIColor.collectionViewBackgroundColor
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = PresetUICollectionViewCompositionalLayout { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            
            switch sectionKind {
            case .topBar:
                return PresetUICollectionViewCompositionalLayout.topBarSectionLayout()
            case .textField:
                return PresetUICollectionViewCompositionalLayout.textFieldSectionLayout()
            case .categories:
                return PresetUICollectionViewCompositionalLayout.categoriesSectionLayout()
            case .predictiveText:
                return PresetUICollectionViewCompositionalLayout.predictiveTextSectionLayout()
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
            case .predictiveText(let predictiveText):
                return self.setupCell(reuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: predictiveText.text)
            case .presetItem(let preset):
                return self.setupCell(reuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, indexPath: indexPath, title: preset)
            case .key(let char):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardKeyCollectionViewCell
                cell.setup(title: char)
                return cell
            case .keyboardFunctionButton(let functionType):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardKeyCollectionViewCell
                cell.setup(with: functionType.image)
                return cell
            }
        })
        
        updateSnapshot()
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        
        snapshot.appendSections([.topBar])
        snapshot.appendItems([.topBarButton(.repeatSpokenText), .topBarButton(.toggleKeyboard)])
        
        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField(currentSpeechText)])
        
        if showKeyboard {
            snapshot.appendSections([.predictiveText])
            if predictions.isEmpty {
                 snapshot.appendItems([.predictiveText(TextPrediction(text: "")),
                                       .predictiveText(TextPrediction(text: "")),
                                       .predictiveText(TextPrediction(text: "")),
                                       .predictiveText(TextPrediction(text: ""))])
            } else {
                snapshot.appendItems([.predictiveText(TextPrediction(text: predictions[safe: 0]?.text ?? "")),
                                      .predictiveText(TextPrediction(text: predictions[safe: 1]?.text ?? "")),
                                      .predictiveText(TextPrediction(text: predictions[safe: 2]?.text ?? "")),
                                      .predictiveText(TextPrediction(text: predictions[safe: 3]?.text ?? ""))])
            }
            
            snapshot.appendSections([.keyboard])
            snapshot.appendItems("QWERTYUIOPASDFGHJKL".map { ItemWrapper.key("\($0)") })
            snapshot.appendItems([.keyboardFunctionButton(.clear), .keyboardFunctionButton(.backspace)])
            snapshot.appendItems("ZXCVBNM".map { ItemWrapper.key("\($0)") })
            snapshot.appendItems([.keyboardFunctionButton(.space), .keyboardFunctionButton(.speak)])
        } else {
            snapshot.appendSections([.categories])
            snapshot.appendItems([.category(.category1), .category(.category2), .category(.category3), .category(.category4)])
            
            snapshot.appendSections([.presets])
            snapshot.appendItems(categoryPresets[selectedCategory]!)
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
        case .category, .presetItem, .topBarButton, .predictiveText, .keyboardFunctionButton, .key:
            return true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField:
            return false
        case .category, .presetItem, .topBarButton, .predictiveText, .keyboardFunctionButton, .key:
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
                guard !isShowingHintText else {
                    break
                }
                AVSpeechSynthesizer.shared.speak(currentSpeechText)
            case .toggleKeyboard:
                showKeyboard.toggle()
                
                // TODO: discuss with design if we want to cache the user's currently-entered text instead
                // of just clearing it
                currentSpeechText = showKeyboard ? HintText.keyboard.rawValue : HintText.preset.rawValue
            }
        case .presetItem(let text):
            currentSpeechText = text
            // Dispatch to get off the main queue for performance
            DispatchQueue.global(qos: .userInitiated).async {
                AVSpeechSynthesizer.shared.speak(text)
            }
        case .category(let category):
            selectedCategory = category
            return
        case .keyboardFunctionButton(let functionType):
            switch functionType {
            case .space:
                didSelectCharacter(" ")
            case .speak:
                guard !isShowingHintText else {
                    break
                }
                AVSpeechSynthesizer.shared.speak(currentSpeechText)
            case .clear:
                currentSpeechText = ""
            case .backspace:
                currentSpeechText = String(currentSpeechText.dropLast())
            }
        case .key(let char):
            didSelectCharacter(char)
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
        case .presetItem, .topBarButton, .keyboardFunctionButton:
            return true
        case .category, .textField, .key, .predictiveText:
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
    
    // MARK: - KeyboardSelectionDelegate
    func didSelectCharacter(_ character: String) {
        if isShowingHintText {
            currentSpeechText = ""
        }
        
        currentSpeechText.append(character)
    }
}
