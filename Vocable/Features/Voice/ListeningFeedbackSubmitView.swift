//
//  ListeningFeedbackSubmitView.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit
import SwiftUI

enum ListeningFeedbackUserDefaultsKey {
    static let showsHintText = "showsHintText"
    static let hidesHintTextAfterFirstSubmission = "hidesHintTextAfterFirstSubmission"
    static let hasSubmittedFeedback = "hasSubmittedFeedback"
}

final class ListeningFeedbackSubmitView: UIView, UIContextMenuInteractionDelegate {

    // MARK: Properties

    @PublishedDefault(key: ListeningFeedbackUserDefaultsKey.showsHintText, defaultValue: false)
    private var showsHintText

    @PublishedDefault(key: ListeningFeedbackUserDefaultsKey.hidesHintTextAfterFirstSubmission, defaultValue: false)
    private var hidesHintTextAfterFirstSubmission

    @PublishedDefault(key: ListeningFeedbackUserDefaultsKey.hasSubmittedFeedback, defaultValue: false)
    private var hasSubmittedFeedback

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

    private func commonInit() {
        let font: UIFont = sizeClass == .hRegular_vRegular
                           ? .systemFont(ofSize: 34, weight: .bold)
                           : .systemFont(ofSize: 22, weight: .bold)
        // TODO: localize and finalize copy
        submitButton.setTitle("Submit Review", for: .normal)
        submitButton.titleLabel?.font = font
        submitButton.contentEdgeInsets = .uniform(16)
        submitButton.isUserInteractionEnabled = true
        submitButton.addTarget(self, action: #selector(handleSubmitButton(_:)), for: .primaryActionTriggered)

        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.isUserInteractionEnabled = true

        infoButton.addInteraction(UIContextMenuInteraction(delegate: self))

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
                                     stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)])
    }

    @objc
    private func handleSubmitButton(_ sender: Any?) {
        hasSubmittedFeedback = true
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
