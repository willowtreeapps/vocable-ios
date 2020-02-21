//
//  TextSelectionViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation

class PresetsViewController: UICollectionViewController, PageIndicatorDelegate {
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    private var selectedCategory: PresetCategory = .category1 {
        didSet {
            reloadPresets()
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
        case topBar
        case textField
        case categories
        case predictiveText
        case presets
        case keyboard
    }
    
    enum ItemWrapper: Hashable {
        case textField(NSAttributedString)
        case topBarButton(TopBarButton)
        case paginatedCategories
        case suggestionText(TextSuggestion)
        case paginatedPresets
        case key(String)
        case keyboardFunctionButton(KeyboardFunctionButton)
        case pageIndicator((String))
        indirect case pagination(ItemWrapper, UIPageViewController.NavigationDirection)
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
                return UIImage(named: "underscore")!
            case .speak:
                return UIImage(named: "Speak")!
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
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectPreset(notification:)), name: .didSelectPresetNotificationName, object: nil)
    }
    
    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        
        collectionView.register(UINib(nibName: "TextFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextFieldCollectionViewCell")
        collectionView.register(UINib(nibName: "CategoryItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryItemCollectionViewCell")
        collectionView.register(UINib(nibName: "PresetItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PresetItemCollectionViewCell")
        collectionView.register(UINib(nibName: "PaginationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PaginationCollectionViewCell")
        collectionView.register(UINib(nibName: "CategoryPaginationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryPaginationCollectionViewCell")
        collectionView.register(UINib(nibName: "PresetPaginationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PresetPaginationCollectionViewCell")
        collectionView.register(UINib(nibName: "KeyboardKeyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KeyboardKeyCollectionViewCell")
        collectionView.register(UINib(nibName: "SuggestionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SuggestionCollectionViewCell")
        collectionView.register(UINib(nibName: "PageIndicatorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PageIndicatorCollectionViewCell")
        
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.collectionViewBackgroundColor
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = PresetUICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
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
                
                return PresetUICollectionViewCompositionalLayout.presetsSectionLayout(for: layoutEnvironment)
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
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: TextFieldCollectionViewCell.reuseIdentifier, for: indexPath) as! TextFieldCollectionViewCell
                cell.setup(title: title)
                return cell
            case .topBarButton(let buttonType):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
                cell.setup(with: buttonType.image)
                return cell
            case .paginatedCategories:
                return self.collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryPaginationCollectionViewCell", for: indexPath) as! CategoryPaginationCollectionViewCell
            case .suggestionText(let predictiveText):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SuggestionCollectionViewCell.reuseIdentifier, for: indexPath) as! SuggestionCollectionViewCell
                cell.setup(title: predictiveText.text)
                return cell
            case .paginatedPresets:
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PresetPaginationCollectionViewCell", for: indexPath) as! PresetPaginationCollectionViewCell
                cell.selectedCategory = self.selectedCategory
                return cell
            case .key(let char):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardKeyCollectionViewCell
                cell.setup(title: char)
                return cell
            case .keyboardFunctionButton(let functionType):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardKeyCollectionViewCell
                cell.setup(with: functionType.image)
                return cell
            case .pageIndicator(let title):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PageIndicatorCollectionViewCell", for: indexPath) as! PageIndicatorCollectionViewCell
                cell.pageInfo = title
                return cell
            case .pagination(let itemIdentifier, let direction):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "PaginationCollectionViewCell", for: indexPath) as! PaginationCollectionViewCell
                cell.paginationDirection = direction
                
                switch itemIdentifier {
                case .paginatedCategories:
                    cell.fillColor = .categoryBackgroundColor
                case .paginatedPresets:
                    cell.fillColor = .defaultCellBackgroundColor
                default:
                    break
                }
                
                return cell
            }
        })
        
        updateSnapshot()
    }
    
    // MARK: - NSDiffableDataSourceSnapshot construction

    func updateSnapshot(animated: Bool = true) {

        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        
        snapshot.appendSections([.topBar])
        snapshot.appendItems([.topBarButton(.repeatSpokenText), .topBarButton(.toggleKeyboard)])
        
        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField(textTransaction.attributedText)])
        
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
            snapshot.appendItems("QWERTYUIOPASDFGHJKL".map { ItemWrapper.key("\($0)") })
            snapshot.appendItems([.keyboardFunctionButton(.clear), .keyboardFunctionButton(.backspace)])
            snapshot.appendItems("ZXCVBNM".map { ItemWrapper.key("\($0)") })
            snapshot.appendItems([.keyboardFunctionButton(.space), .keyboardFunctionButton(.speak)])
        } else {
            snapshot.appendSections([.categories])
            snapshot.appendItems([.pagination(.paginatedCategories, .reverse)])
            snapshot.appendItems([.paginatedCategories])
            snapshot.appendItems([.pagination(.paginatedCategories, .forward)])
            
            snapshot.appendSections([.presets])
            snapshot.appendItems([.paginatedPresets])
            snapshot.appendItems([.pagination(.paginatedPresets, .reverse), .pageIndicator("Page 1 of 4"), .pagination(.paginatedPresets, .forward)])
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func reloadPresets() {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([.paginatedPresets])
        dataSource.apply(snapshot)
    }
    
    // MARK: - Collection View Delegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField, .paginatedCategories, .paginatedPresets, .pageIndicator:
            return false
        case .topBarButton, .keyboardFunctionButton, .key, .pagination:
            return true
        case .suggestionText(let suggestion):
            return !suggestion.text.isEmpty
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField, .paginatedCategories, .paginatedPresets, .pageIndicator:
            return false
        case .topBarButton, .keyboardFunctionButton, .key, .pagination:
            return true
        case .suggestionText(let suggestion):
            return !suggestion.text.isEmpty
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PaginationContainerCollectionViewCell,
            let childViewController = cell.pageViewController {
            let childContainerView = cell.contentView
            
            // FIXME: the child is retained forever
            addChild(childViewController)
            childViewController.view.frame = childContainerView.frame.inset(by: childContainerView.layoutMargins)
            childContainerView.addSubview(childViewController.view)
            childViewController.didMove(toParent: self)
            
            if let presetsPageViewController = childViewController as? PresetsPageViewController {
                presetsPageViewController.pageIndicatorDelegate = self
            }
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
                guard !textTransaction.isHint else {
                    break
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    AVSpeechSynthesizer.shared.speak(self.textTransaction.text)
                }
            case .toggleKeyboard:
                showKeyboard.toggle()
                
                // TODO: discuss with design if we want to cache the user's currently-entered text instead
                // of just clearing it

                let newText = showKeyboard ? HintText.keyboard.rawValue : HintText.preset.rawValue
                setTextTransaction(TextTransaction(text: newText, isHint: true))
                suggestions = []
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
        case .pagination(let itemIdentifier, let direction):  
            guard let contentItemIndexPath = dataSource.indexPath(for: itemIdentifier) else {
                break
            }
            
            if let paginationCell = collectionView.cellForItem(at: contentItemIndexPath) as? PaginationContainerCollectionViewCell {
                paginationCell.paginate(direction)
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
        case .topBarButton, .keyboardFunctionButton, .key, .suggestionText, .pagination, .paginatedPresets, .pageIndicator:
            return true
        case .paginatedCategories, .textField:
            return false
        }
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
    
    @objc private func didSelectPreset(notification: NSNotification) {
        guard let text = notification.object as? String else {
            return
        }
        
        setTextTransaction(TextTransaction(text: text))
    }
    
    // MARK: - PageIndicatorDelegate
    func updatePageIndicator(with pageInfo: String) {
        let presetPageIndicatorIdentifier = dataSource.snapshot().itemIdentifiers(inSection: .presets).first {
            guard case .pageIndicator = $0 else {
                return false
            }
            
            return true
        }
        
        guard let pageIndicatorIdentifier = presetPageIndicatorIdentifier,
            let pageIndicatorIndexPath = dataSource.indexPath(for: pageIndicatorIdentifier) else {
            return
        }
        
         if let pageIndicatorCell = collectionView.cellForItem(at: pageIndicatorIndexPath) as? PageIndicatorCollectionViewCell {
            pageIndicatorCell.pageLabel.text = pageInfo
        }
    }
}
