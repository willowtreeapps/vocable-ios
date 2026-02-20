//
//  PersonalVoiceViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/26/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Combine

@available(iOS 17.0, *)
final class PersonalVoiceViewController: PagingCarouselViewController {
        
    private typealias DataSource = CarouselCollectionViewDataSourceProxy<Int, VoiceProfileItem>
    private typealias CellRegistration = UICollectionView.CellRegistration<VocableListCell, VoiceProfileItem>
    
    private var dataSource: DataSource!
    private var cellRegistration: CellRegistration!
    private let authorizationController = PersonalVoicePermissionPromptController()
    
    private let previewController = VoiceProfilePreviewController(context: .personalVoice)
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLayoutForCurrentTraitCollection()

        setupNavigationBar()
        setupCollectionView()
        updateDataSource()
        
        Publishers.CombineLatest(previewController.$items, authorizationController.$state)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (items, state) in
                self?.updateDataSource(items: items, authorizationState: state)
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Re-evaluate status when the screen appears (e.g. after returning from Settings or when API state updates)
        updateDataSource()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        updateBackgroundViewLayoutMargins()
    }

    private func setupNavigationBar() {
        navigationBar.title = String(localized: "personal_voices.title")
    }

    private func setupCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelectionDuringEditing = true
        collectionView.backgroundColor = .collectionViewBackgroundColor
        
        let cellRegistration = CellRegistration { [weak self] cell, _, item in
            guard let self else { return }
            cell.contentConfiguration = VocableListContentConfiguration.voiceProfileItem(
                item,
                controller: self.previewController
            ) { [weak self] in
                self?.handleVoiceSelection(item.voice)
            }
        }
        
        let dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, voice) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: voice
            )
        }
        self.dataSource = dataSource
        self.cellRegistration = cellRegistration
    }
    
    private func updateDataSource(
        items: [VoiceProfileItem]? = nil,
        previewing previewVoice: AVSpeechSynthesisVoice? = nil,
        authorizationState: PersonalVoicePermissionPromptController.PersonalVoicePermissionEmptyState? = nil
    ) {
        let authorizationState = authorizationState ?? authorizationController.state
        let items = items ?? previewController.items
        var snapshot = NSDiffableDataSourceSnapshot<Int, VoiceProfileItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)

        // Show device/OS incompatibility when Personal Voice is not supported (same pattern as Listening Mode / head tracking)
        if !AppConfig.isPersonalVoiceSupported {
            isPaginationViewHidden = true
            setBackgroundView(EmptyStateView(type: PersonalVoiceEmptyState.unsupported))
            return
        }

        isPaginationViewHidden = false

        if let authorizationState {
            setBackgroundView(EmptyStateView(type: authorizationState.state, action: authorizationState.action))
        } else if snapshot.itemIdentifiers.isEmpty {
            setBackgroundView(EmptyStateView(type: PersonalVoiceEmptyState.noContent))
        } else {
            setBackgroundView(nil)
        }
    }
    
    private func setBackgroundView(_ view: UIView?) {
        collectionView.backgroundView = view
        updateBackgroundViewLayoutMargins()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {
        collectionView.layout.interItemSpacing = .init(interRowSpacing: 8, interColumnSpacing: 30)

        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(100))
        case .hCompact_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(64))
        case .hCompact_vCompact, .hRegular_vCompact:
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(64))
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    private func updateBackgroundViewLayoutMargins() {
        guard let backgroundView = collectionView.backgroundView else { return }
        backgroundView.directionalLayoutMargins.leading = view.directionalLayoutMargins.leading
        backgroundView.directionalLayoutMargins.trailing = view.directionalLayoutMargins.trailing
    }
    
    fileprivate func handleVoiceSelection(_ voice: AVSpeechSynthesisVoice) {
        AppConfig.selectedVoiceIdentifier = voice.identifier
        updateDataSource()
    }
}

enum PersonalVoiceEmptyState: EmptyStateRepresentable {

    case denied
    case notAuthorized
    case noContent
    case unsupported

    var title: String {
        return switch self {
        case .denied: String(localized: "personal_voices.empty_state.denied.title")
        case .notAuthorized: String(localized: "personal_voices.empty_state.not_authorized.title")
        case .noContent: String(localized: "personal_voices.empty_state.no_content.title")
        case .unsupported: String(localized: "personal_voices.empty_state.unsupported.title")
        }
    }

    var description: String? {
        switch self {
        case .denied:
            let format = String(localized: "personal_voices.empty_state.denied.description")
            return String(format: format, UIDevice.current.model)
        case .noContent:
            let format = String(localized: "personal_voices.empty_state.no_content.description")
            return String(format: format, UIDevice.current.model)
        case .notAuthorized:
            return String(localized: "personal_voices.empty_state.not_authorized.description")
        case .unsupported:
            let model = UIDevice.current.localizedModel
            let systemName = UIDevice.current.systemName
            let systemVersion = UIDevice.current.systemVersion
            let format = String(localized: "personal_voices.empty_state.unsupported.description")
            return String(format: format, model, systemName, systemVersion)
        }
    }

    var buttonTitle: String? {
        return switch self {
        case .denied: String(localized: "personal_voices.empty_state.denied.button.title")
        case .notAuthorized: String(localized: "personal_voices.empty_state.not_authorized.button.title")
        case .noContent, .unsupported: nil
        }
    }
}
