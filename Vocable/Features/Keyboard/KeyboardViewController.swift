//
//  KeyboardViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/22/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import AVKit
import Combine

class KeyboardViewController: UICollectionViewController {
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    private var disposables = Set<AnyCancellable>()
    
    private var _textTransaction = TextTransaction(text: "") {
        didSet {
            attributedText = _textTransaction.attributedText
        }
    }
    
    private var textTransaction: TextTransaction {
        return _textTransaction
    }
    
    private let textExpression = TextExpression()
    
    private var suggestions: [TextSuggestion] = [] {
        didSet {
            updateSnapshot()
        }
    }
    
    @PublishedValue
    var attributedText: NSAttributedString?
    
    private enum ItemWrapper: Hashable {
        case key(String)
        case keyboardFunctionButton(KeyboardFunctionButton)
        case suggestionText(TextSuggestion)
    }
    
    private enum Section: Int, CaseIterable {
        case suggestions
        case keyboard
    }

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        $attributedText.receive(on: DispatchQueue.main).sink { [weak self] (newAttributedText) in
            guard let self = self, let newAttributedText = newAttributedText,
                newAttributedText.string != self._textTransaction.text else { return }
            self._textTransaction = TextTransaction(text: newAttributedText.string, intent: .lastCharacter)
        }.store(in: &disposables)
        
        setupCollectionView()
        configureDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
    }
    
    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        
        collectionView.register(UINib(nibName: "KeyboardKeyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "SuggestionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SuggestionCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "SpeakFunctionKeyboardKeyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SpeakFunctionKeyboardKeyCollectionViewCell.reuseIdentifier)

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.collectionViewBackgroundColor
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .suggestionText(let predictiveText):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestionCollectionViewCell.reuseIdentifier, for: indexPath) as! SuggestionCollectionViewCell
                cell.setup(title: predictiveText.text)
                return cell
            case .key(let char):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardKeyCollectionViewCell
                cell.setup(title: char)
                return cell
            case .keyboardFunctionButton(let functionType):
                if functionType == .speak {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpeakFunctionKeyboardKeyCollectionViewCell.reuseIdentifier, for: indexPath) as! SpeakFunctionKeyboardKeyCollectionViewCell
                    cell.setup(with: functionType.image)
                    return cell
                }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyboardKeyCollectionViewCell.reuseIdentifier, for: indexPath) as! KeyboardKeyCollectionViewCell
                cell.setup(with: functionType.image)
                return cell
            }
        })
        
        updateSnapshot()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = PresetCollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            let sectionKind = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            
            switch sectionKind {
            case .keyboard:
                return PresetCollectionViewCompositionalLayout.editTextKeyboardLayout(with: layoutEnvironment)
            case .suggestions:
                return PresetCollectionViewCompositionalLayout.suggestiveTextSectionLayout(with: layoutEnvironment)
            }
        }
        layout.register(CategorySectionBackground.self, forDecorationViewOfKind: "CategorySectionBackground")
        return layout
    }
    
    private func updateSnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        
        // Snapshot construction
        snapshot.appendSections([.suggestions])
        
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
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular && !AppConfig.isCompactQWERTYKeyboardEnabled {
            snapshot.appendItems(KeyboardLocale.current.compactPortraitKeyMapping.map { ItemWrapper.key("\($0)") })
        } else {
            snapshot.appendItems(KeyboardLocale.current.landscapeKeyMapping.map { ItemWrapper.key("\($0)") })
        }
        
        snapshot.appendItems([.keyboardFunctionButton(.clear), .keyboardFunctionButton(.space), .keyboardFunctionButton(.backspace), .keyboardFunctionButton(.speak)])
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    // MARK: - Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        for selectedPath in collectionView.indexPathsForSelectedItems ?? [] {
            if selectedPath.section == indexPath.section && selectedPath != indexPath {
                collectionView.deselectItem(at: selectedPath, animated: true)
            }
        }
        
        switch selectedItem {
        case .keyboardFunctionButton(let functionType):
            switch functionType {
            case .space:
                setTextTransaction(textTransaction.appendingCharacter(with: " "))
                
            case .speak:
                guard !textTransaction.isHint else {
                    break
                }

                Analytics.shared.track(.keyboardPhraseSpoken)
                let utterance = textTransaction.text
                DispatchQueue.global(qos: .userInitiated).async {
                    AVSpeechSynthesizer.shared.speak(utterance, language: AppConfig.activePreferredLanguageCode)
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
        }
        
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .keyboardFunctionButton, .key:
            return true
        case .suggestionText(let suggestion):
            return !suggestion.text.isEmpty
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .keyboardFunctionButton, .key:
            return true
        case .suggestionText(let suggestion):
            return !suggestion.text.isEmpty
        }
    }
    
    private func setTextTransaction(_ transaction: TextTransaction) {
        _textTransaction = transaction
        
        // Update suggestions
        if textTransaction.isHint || textTransaction.text.last == " " {
            suggestions = []
        } else {
            textExpression.replace(text: textTransaction.text)
            suggestions = textExpression.suggestions().map({ TextSuggestion(text: $0) })
        }
        
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot)
        
        DispatchQueue.main.async { [weak self] in
            self?.updateSnapshot()
        }
    }
    
}
