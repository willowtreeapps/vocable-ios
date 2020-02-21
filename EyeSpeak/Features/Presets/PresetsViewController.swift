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
    private var selectedCategory: PresetCategory = .category1 {
        didSet {
            self.updateSnapshot()
        }
    }
    
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

    private enum HintText: String, CaseIterable {
        case preset = "Select something below to speak"
        case keyboard = "Select letters below to start typing."
    }
    
    private var _textTransaction = TextTransaction(text: HintText.preset.rawValue)
    
    private var textTransaction: TextTransaction {
        return _textTransaction
    }
    
    let textExpression = TextExpression()
    
    enum Section: Int, CaseIterable {
        case textField
        case categories
        case predictiveText
        case presets
        case keyboard
    }
    
    enum ItemWrapper: Hashable {
        case textField(NSAttributedString)
        case topBarButton(TopBarButton)
        case category
        case suggestionText(TextSuggestion)
        case presetItem(String)
        case key(String)
        case keyboardFunctionButton(KeyboardFunctionButton)
        case pagination(UIPageViewController.NavigationDirection)
    }
    
    enum TopBarButton: String {
        case save
        case toggleKeyboard
        case togglePreset
        case settings
        
        var image: UIImage? {
            switch self {
            case .save:
                return UIImage(systemName: "suit.heart")
            case .toggleKeyboard:
                return UIImage(systemName: "keyboard")
            case .togglePreset:
                return UIImage(systemName: "text.bubble.fill")
            case .settings:
                return UIImage(systemName: "gear")
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
                return UIImage(systemName: "delete.left")!
            case .space:
                return UIImage(named: "underscore")!
            case .speak:
                return UIImage(named: "speak")!
            }
        }
    }
    
    private var showKeyboard: Bool = false {
        didSet {
            self.updateSnapshot()
        }
    }
    
    private var suggestions: [TextSuggestion] = [] {
        didSet {
            updateSnapshot()
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        configureDataSource()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectCategory(notification:)), name: .didSelectCategoryNotificationName, object: nil)
    }
    
    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        collectionView.register(UINib(nibName: "TextFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextFieldCollectionViewCell")
        collectionView.register(UINib(nibName: "CategoryItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryItemCollectionViewCell")
        collectionView.register(UINib(nibName: "PresetItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PresetItemCollectionViewCell")
        collectionView.register(UINib(nibName: "PaginationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PaginationCollectionViewCell")
        collectionView.register(UINib(nibName: "CategoryContainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryContainerCollectionViewCell")
        collectionView.register(UINib(nibName: "KeyboardKeyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KeyboardKeyCollectionViewCell")
        collectionView.register(UINib(nibName: "SuggestionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SuggestionCollectionViewCell")

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.collectionViewBackgroundColor
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = PresetUICollectionViewCompositionalLayout { (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            
            switch sectionKind {
            case .textField:
                return PresetUICollectionViewCompositionalLayout.textFieldSectionLayout(with: environment)
            case .categories:
                return PresetUICollectionViewCompositionalLayout.categoriesSectionLayout(with: environment)
            case .predictiveText:
                return PresetUICollectionViewCompositionalLayout.predictiveTextSectionLayout(with: environment)
            case .presets:
                guard !self.showKeyboard else {
                    return nil
                }
                
                return PresetUICollectionViewCompositionalLayout.presetsSectionLayout(with: environment)
            case .keyboard:
                return PresetUICollectionViewCompositionalLayout.keyboardSectionLayout(with: environment)
            }
        }
        layout.register(CategorySectionBackground.self, forDecorationViewOfKind: "CategorySectionBackground")
        return layout
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (_: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .textField(let title):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: TextFieldCollectionViewCell.reuseIdentifier, for: indexPath) as! TextFieldCollectionViewCell
                cell.setup(title: title)
                return cell
            case .topBarButton(let buttonType):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
                cell.setup(with: buttonType.image)
                return cell
            case .category:
                return self.collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryContainerCollectionViewCell", for: indexPath) as! CategoryContainerCollectionViewCell
            case .suggestionText(let predictiveText):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SuggestionCollectionViewCell.reuseIdentifier, for: indexPath) as! SuggestionCollectionViewCell
                cell.setup(title: predictiveText.text)
                return cell
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
            case .pagination(let direction):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PaginationCollectionViewCell", for: indexPath) as! PaginationCollectionViewCell
                cell.paginationDirection = direction
                return cell
            }
        })
        
        updateSnapshot()
    }
    
    // MARK: - NSDiffableDataSourceSnapshot construction

    func updateSnapshot(animated: Bool = true) {

        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        
        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField(textTransaction.attributedText), .topBarButton(.save), .topBarButton(.togglePreset), .topBarButton(.settings)])
        
        if showKeyboard {
            snapshot.appendSections([.predictiveText])
            
            if suggestions.isEmpty {
                 snapshot.appendItems([.suggestionText(TextSuggestion(text: "")),
                                       .suggestionText(TextSuggestion(text: "")),
                                       .suggestionText(TextSuggestion(text: "")),
                                       .suggestionText(TextSuggestion(text: ""))])
            } else {
                snapshot.appendItems([.suggestionText(TextSuggestion(text: (suggestions[safe: 0]?.text ?? ""))),
                                      .suggestionText(TextSuggestion(text: (suggestions[safe: 1]?.text ?? ""))),
                                      .suggestionText(TextSuggestion(text: (suggestions[safe: 2]?.text ?? ""))),
                                      .suggestionText(TextSuggestion(text: (suggestions[safe: 3]?.text ?? "")))])
            }
            
            snapshot.appendSections([.keyboard])
            snapshot.appendItems("QWERTYUIOPASDFGHJKL'ZXCVBNM,.?".map { ItemWrapper.key("\($0)") })
            snapshot.appendItems([.keyboardFunctionButton(.clear), .keyboardFunctionButton(.space), .keyboardFunctionButton(.backspace), .keyboardFunctionButton(.speak)])
        } else {
            snapshot.appendSections([.categories])
            snapshot.appendItems([.pagination(.reverse)])
            snapshot.appendItems([.category])
            snapshot.appendItems([.pagination(.forward)])
            
            snapshot.appendSections([.presets])
            snapshot.appendItems(categoryPresets[selectedCategory]!)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PresetPageControlView", for: indexPath) as! PresetPageControlReusableView
            self?.pageControl = view.pageControl
            return view
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - Collection View Delegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField:
            return false
        case .category, .presetItem, .topBarButton, .keyboardFunctionButton, .key, .pagination:
            return true
        case .suggestionText(let suggestion):
            return !suggestion.text.isEmpty
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField:
            return false
        case .category, .presetItem, .topBarButton, .keyboardFunctionButton, .key, .pagination:
            return true
        case .suggestionText(let suggestion):
            return !suggestion.text.isEmpty
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
        
        if orthogonalScrollView == nil && dataSource.snapshot().indexOfSection(.presets) == indexPath.section {
            orthogonalScrollView = locateNearestContainingScrollView(for: cell)
        }
        
        if let cell = cell as? CategoryContainerCollectionViewCell {
            let childContainerView = cell.contentView
            let childViewController = cell.pageViewController
            
            addChild(childViewController)
            childViewController.view.frame = childContainerView.frame.inset(by: childContainerView.layoutMargins)
            childContainerView.addSubview(childViewController.view)
            childViewController.didMove(toParent: self)
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
            case .save:
                guard !textTransaction.isHint else {
                    break
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    AVSpeechSynthesizer.shared.speak(self.textTransaction.text)
                }
            case .toggleKeyboard, .togglePreset:
                showKeyboard.toggle()
                
                // TODO: discuss with design if we want to cache the user's currently-entered text instead
                // of just clearing it

                let newText = showKeyboard ? HintText.keyboard.rawValue : HintText.preset.rawValue
                setTextTransaction(TextTransaction(text: newText, isHint: true))
                suggestions = []
            case .settings:
                presentSettingsViewController()
            }
        case .presetItem(let text):
            setTextTransaction(TextTransaction(text: text))
            // Dispatch to get off the main queue for performance
            DispatchQueue.global(qos: .userInitiated).async {
                AVSpeechSynthesizer.shared.speak(self.textTransaction.text)
            }
        case .keyboardFunctionButton(let functionType):
            switch functionType {
            case .space:
                setTextTransaction(textTransaction.appendingCharacter(with: " "))
                suggestions = []
            case .speak:
                guard !textTransaction.isHint else {
                    break
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    AVSpeechSynthesizer.shared.speak(self.textTransaction.text)
                }
            case .clear:
                setTextTransaction(TextTransaction(text: "", intent: .none))
            case .backspace:
                setTextTransaction(textTransaction.deletingLastToken())
            }
        case .key(let char):
            setTextTransaction(textTransaction.appendingCharacter(with: char))
        case .suggestionText(let suggestion):
            setTextTransaction(textTransaction.insertingSuggestion(with: suggestion.text))
        case .pagination(let direction):
            let snapshot = dataSource.snapshot()
            guard let section = snapshot.sectionIdentifier(containingItem: selectedItem) else {
                break
            }
            
            let sectionContentIdentifiers = snapshot.itemIdentifiers(inSection: section).filter { $0 != .pagination(.forward) && $0 != .pagination(.reverse) }
            
            guard let contentItemIdentifier = sectionContentIdentifiers.first,
                let contentItemIndexPath = dataSource.indexPath(for: contentItemIdentifier) else {
                break
            }
            
            if let categoryContainerCell = collectionView.cellForItem(at: contentItemIndexPath) as? CategoryContainerCollectionViewCell {
                categoryContainerCell.paginate(direction)
            }
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
        case .presetItem, .topBarButton, .keyboardFunctionButton, .key, .suggestionText, .pagination:
            return true
        case .category, .textField:
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
    
    private func setTextTransaction(_ transaction: TextTransaction) {
        self._textTransaction = transaction
        
        // Update suggestions
        if textTransaction.isHint || textTransaction.text.last == " " {
            suggestions = []
        } else {
            textExpression.replace(text: textTransaction.text)
            suggestions = textExpression.suggestions().map({ TextSuggestion(text: $0) })
        }
    }
    
    @objc private func didSelectCategory(notification: NSNotification) {
        guard let category = notification.object as? PresetCategory else {
            return
        }
        
        selectedCategory = category
    }
    
    private func presentSettingsViewController() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
