//
//  ListeningFeedbackSubmitView.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import UIKit
import SwiftUI

enum ListeningFeedbackUserDefaultsKey {
    static let showsHintText = "showsHintText"
    static let hidesHintTextAfterFirstSubmission = "hidesHintTextAfterFirstSubmission"
    static let hasSubmittedFeedback = "hasSubmittedFeedback"
    static let disableShareUntilSubmitted = "disableShareUntilSubmitted"
}

final class ListeningFeedbackSubmitView: UIView, UIContextMenuInteractionDelegate {

    // MARK: Properties
    private var disposables = Set<AnyCancellable>()

    @PublishedDefault(key: ListeningFeedbackUserDefaultsKey.showsHintText, defaultValue: false)
    private var showsHintText

    @PublishedDefault(key: ListeningFeedbackUserDefaultsKey.hidesHintTextAfterFirstSubmission, defaultValue: false)
    private var hidesHintTextAfterFirstSubmission

    @PublishedDefault(key: ListeningFeedbackUserDefaultsKey.hasSubmittedFeedback, defaultValue: false)
    var hasSubmittedFeedback

    @PublishedDefault(key: ListeningFeedbackUserDefaultsKey.disableShareUntilSubmitted, defaultValue: false)
    private var disableShareUntilSubmitted

    let hintLabel = UILabel()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [hintLabel, stackView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [submitButton, infoButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    let submitButton = GazeableButton()
    let infoButton = GazeableButton()

    // MARK: Initializers

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func setupPublishers() {
        Publishers.Merge3($showsHintText, $hidesHintTextAfterFirstSubmission, $hasSubmittedFeedback)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
            self?.handleDebugOptionChanges()
        }.store(in: &disposables)
    }

    private func commonInit() {
        setupPublishers()
        handleDebugOptionChanges()
        hintLabel.text = "To help improve listening mode, you can\nanonymously share the last spoken phrase."
        hintLabel.font = .systemFont(ofSize: 15)
        hintLabel.textColor = .gray
        hintLabel.numberOfLines = 2
        hintLabel.textAlignment = .center

        let font: UIFont = sizeClass == .hRegular_vRegular
                           ? .systemFont(ofSize: 34, weight: .bold)
                           : .systemFont(ofSize: 22, weight: .bold)
        // TODO: localize and finalize copy
        submitButton.setTitle("Share", for: .normal)
        submitButton.titleLabel?.font = font
        submitButton.contentEdgeInsets = .uniform(16)
        submitButton.isUserInteractionEnabled = true

        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.isUserInteractionEnabled = true

        infoButton.addInteraction(UIContextMenuInteraction(delegate: self))

        addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([containerStackView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
                                     containerStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     containerStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)])
    }

    private func handleDebugOptionChanges() {
        hintLabel.isVisible = showsHintText && (!hasSubmittedFeedback || !hidesHintTextAfterFirstSubmission)
        submitButton.isEnabled = hasSubmittedFeedback || !disableShareUntilSubmitted
        layoutIfNeeded()
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            let adjustAction = UIAction(title: "Adjust...", image: nil) { _ in
                if #available(iOS 15.0, *) {
                    self.presentAdjustmentPopover()
                }
            }
            return UIMenu(title: "", children: [adjustAction])
        })
    }

    @available(iOS 15.0, *)
    private func presentAdjustmentPopover() {
        let vc = UIHostingController(rootView: ListenModeDebugOptionsView())
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.adaptiveSheetPresentationController.detents = [.medium()]
        vc.popoverPresentationController?.sourceView = infoButton
        self.window?.rootViewController?.present(vc, animated: true)
    }
}

extension UIView {

    public var isVisible: Bool {
        get {
            return !isHidden
        }
        set(visible) {
            isHidden = !visible
        }
    }

}
