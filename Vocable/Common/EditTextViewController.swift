//
//  EditTextViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreData
import Combine

final class EditTextViewController: UIViewController, UICollectionViewDelegate {
    
    private var disposables = Set<AnyCancellable>()

    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    @IBOutlet private var collectionView: UICollectionView!
    
    private var keyboardViewController: KeyboardViewController?
    
    var displayText: NSMutableAttributedString? {
        didSet {
            updateSnapshot()
        }
    }

    private var shouldAllowSaving = false {
        didSet {
            updateSaveButtonCell()
        }
    }
    
    // TODO: Need to figure this out
    private var textHasChanged = false
//    private var textHasChanged: Bool {
//        return text != textTransaction.text
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "KeyboardViewController" {
           keyboardViewController = segue.destination as? KeyboardViewController
        }
    }
  
    var editTextCompletionHandler: (String) -> Void = { (_) in
        assertionFailure("Completion not handled")
    }
    
    private enum ItemWrapper: Hashable {
        case textField(NSAttributedString)
        case topBarButton(TopBarButton)
    }
    
    private enum Section: Int, CaseIterable {
        case textField
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardViewController?.$attrText.receive(on: DispatchQueue.main)
            .assign(to: \EditTextViewController.displayText, on: self)
            .store(in: &disposables)
        setupCollectionView()
        configureDataSource()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
    }

    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        
        collectionView.register(UINib(nibName: "TextFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextFieldCollectionViewCell")
        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "SuggestionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SuggestionCollectionViewCell")
        
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.collectionViewBackgroundColor
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(PresetPageControlReusableView.self, forSupplementaryViewOfKind: "footerPageIndicator", withReuseIdentifier: "PresetPageControlView")
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
                if buttonType == .confirmEdit {
                    cell.isEnabled = self.shouldAllowSaving
                } else {
                    cell.isEnabled = true
                }
                cell.setup(with: buttonType.image)
                return cell
            }
        })
        
        updateSnapshot()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = PresetCollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            return self.topBarLayout()
        }
        layout.register(CategorySectionBackground.self, forDecorationViewOfKind: "CategorySectionBackground")
        return layout
    }
    
    private func updateSnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        
        // Snapshot construction
        snapshot.appendSections([.textField])
        if traitCollection.horizontalSizeClass == .compact
            && traitCollection.verticalSizeClass == .regular {
            snapshot.appendItems([.topBarButton(.close),
                                  .topBarButton(.confirmEdit),
                                  .textField(displayText ?? NSMutableAttributedString(string: ""))
            ])
        } else {
            snapshot.appendItems([.topBarButton(.close),
                                  .textField(displayText ?? NSMutableAttributedString(string: "")),
                                  .topBarButton(.confirmEdit)])
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func updateSaveButtonCell() {
        guard let indexPath = dataSource.indexPath(for: .topBarButton(.confirmEdit)) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? PresetItemCollectionViewCell else { return }
        cell.isEnabled = shouldAllowSaving
    }
    
    private func topBarLayout() -> NSCollectionLayoutSection {
        var regularWidthContainerGroupLayout: NSCollectionLayoutGroup {
            let textFieldItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(1.0)))
            textFieldItem.contentInsets = .init(top: 4, leading: 16, bottom: 0, trailing: 4)
            
            let functionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.1), heightDimension: .fractionalHeight(1.0)))
            functionItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let subitems = [functionItem, textFieldItem, functionItem]
            
            return NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(1)),
                subitems: subitems)
        }
        
        var compactWidthContainerGroupLayout: NSCollectionLayoutGroup {
            let textFieldItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(2 / 3)))
            
            let functionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1.0)))
            functionItem.contentInsets = .init(top: 4, leading: 0, bottom: 0, trailing: 4)

            let functionItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(1 / 3)),
                subitems: [functionItem, functionItem])
            functionItemGroup.interItemSpacing = .flexible(1)
            
            return NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1)),
                subitems: [functionItemGroup, textFieldItem])
        }
        
        let containerGroup = traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular ? compactWidthContainerGroupLayout : regularWidthContainerGroupLayout
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        return section
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        for selectedPath in collectionView.indexPathsForSelectedItems ?? [] {
            if selectedPath.section == indexPath.section && selectedPath != indexPath {
                collectionView.deselectItem(at: selectedPath, animated: true)
            }
        }
        
        switch selectedItem {
        case .topBarButton(let buttonType):
            (self.view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
            collectionView.deselectItem(at: indexPath, animated: true)
            switch buttonType {
            case .confirmEdit:
                editTextCompletionHandler(displayText?.string ?? "")
                dismiss(animated: true, completion: nil)
            case .close:
                if textHasChanged {
                    handleDismissAlert()
                } else {
                    dismiss(animated: true, completion: nil)
                }
            default:
                break
            }
        default:
            break
        }

        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .topBarButton:
            return true
        case .textField:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField:
            return false
        case .topBarButton(let buttonType):
            if case .confirmEdit = buttonType {
                return shouldAllowSaving
            }
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .textField:
            return false
        case .topBarButton(let buttonType):
            if case .confirmEdit = buttonType {
                return shouldAllowSaving
            }
            return true
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
    
    private func handleDismissAlert() {
        func discardChangesAction() {
            dismiss(animated: true, completion: nil)
        }

        let title = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.title",
                                      comment: "Exit edit sayings alert title")
        let discardButtonTitle = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.button.discard.title",
                                                   comment: "Discard changes alert action title")
        let continueButtonTitle = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.button.continue_editing.title",
                                                    comment: "Continue editing alert action title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: discardButtonTitle, handler: discardChangesAction))
        alert.addAction(GazeableAlertAction(title: continueButtonTitle, style: .bold))
        self.present(alert, animated: true)
    }
}
