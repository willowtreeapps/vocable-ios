//
//  ListeningResponseContentViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 3/12/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import Combine
import OrderedCollections

@available(iOS 14.0, *)
final class ListeningResponseContentViewController: PagingCarouselViewController {

    private var _content: [String] = []
    
    var content: [String] {
        set {
            var uniqueContent = OrderedSet<String>()
            uniqueContent.append(contentsOf: newValue)
            let newContent = uniqueContent.elements
            _content = newContent
            
            var newSnapshot = NSDiffableDataSourceSnapshot<Int, String>()
            newSnapshot.appendSections([0])
            newSnapshot.appendItems(newContent)

            self.diffableDataSource.apply(newSnapshot, animatingDifferences: false)

            self.collectionView.backgroundView = nil
        }
        
        get {
            _content
        }
    }

    @PublishedValue private(set) var lastUtterance: String? = .none

    var disposables = Set<AnyCancellable>()
    var synthesizedSpeechQueue: DispatchQueue!
    var apiClient: ListenAPIClient?
    
    /// When listening mode was used to generate the `Content` displayed, set this to the prompt used to query the API.
    ///
    /// `ListeningResponseContentViewController` will inform the `apiClient` when a choice is selected so that
    /// the conversation history can be added to the context of the query API. When multiple options are selected, the most recent option
    /// is tracked.
    var trackingPrompt: String?

    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: self.collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
        let cell = collectionView.dequeueCell(type: PresetItemCollectionViewCell.self, for: indexPath)
        cell.setup(title: item)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(synthesizedSpeechQueue != nil, "expected queue")

        edgesForExtendedLayout = UIRectEdge.all.subtracting(.top)
        view.layoutMargins.top = 4

        isPaginationViewHidden = true
        updateLayoutForCurrentTraitCollection()

        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
        collectionView.layout.itemAnimationStyle = .verticalTimeline
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateLayoutForCurrentTraitCollection()
        view.backgroundColor = .clear
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath != collectionView.indexPathForGazedItem {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        guard let utterance = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        lastUtterance = utterance

        if let apiClient,
           let trackingPrompt {
            apiClient.userResponded(to: trackingPrompt, with: utterance)
        }
        
        synthesizedSpeechQueue.async {
            AVSpeechSynthesizer.shared.speak(utterance, language: AppConfig.activePreferredLanguageCode)
        }
    }

    private func updateLayoutForCurrentTraitCollection(animated: Bool = false) {

        let responseCount = content.count

        let layout = collectionView.layout
        layout.interItemSpacing = .uniform(8)
        layout.pageInsets.top = 24
        layout.pageInsets.bottom = view.safeAreaInsets.bottom + 24
        layout.pageInsets.left = view.layoutMargins.left + 24
        layout.pageInsets.right = view.layoutMargins.right + 24
        layout.alignment = .center

        switch sizeClass {
        case .hCompact_vRegular:
            // Handset vertical
            if responseCount < 6 {
                layout.numberOfColumns = .fixedCount(1)
                layout.numberOfRows = .fixedCount(responseCount)
            } else {
                layout.numberOfColumns = .fixedCount(2)
                layout.numberOfRows = .fixedCount(Int((Double(responseCount) / 2.0).rounded(.up)))
            }
        case .hCompact_vCompact, .hRegular_vCompact:
            // Handset landscape
            if responseCount < 6 {
                layout.numberOfColumns = .fixedCount(responseCount)
                layout.numberOfRows = .fixedCount(1)
            } else {
                layout.numberOfColumns = .fixedCount(Int((Double(responseCount) / 2.0).rounded(.up)))
                layout.numberOfRows = .fixedCount(2)
            }
        case .hRegular_vRegular:
            // Tablet any
            if responseCount < 6 {
                layout.numberOfColumns = .fixedCount(responseCount)
                layout.numberOfRows = .fixedCount(1, maxHeight: .relative(0.5))
            } else if responseCount == 6 {
                layout.numberOfColumns = .fixedCount(3)
                layout.numberOfRows = .fixedCount(2, maxHeight: .relative(0.5))
            } else {
                layout.numberOfColumns = .fixedCount(3)
                layout.numberOfRows = .flexible(minHeight: .absolute(120), maxHeight: .relative(0.5))
            }
        default:
            break
        }
    }
}
