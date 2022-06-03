//
//  RootViewController.swift
//  Vocable AAC
//
//  Created by Steve Foster on 4/23/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import CoreData
import SwiftUI

@IBDesignable class RootViewController: VocableViewController, ListeningResponseViewControllerDelegate {

    @IBOutlet private weak var outputLabel: UILabel!
    @IBOutlet private weak var outputAlignmentView: UIView!
    @IBOutlet private weak var keyboardButton: GazeableButton!
    @IBOutlet private weak var settingsButton: GazeableButton!

    private let contentLayoutGuide = UILayoutGuide()
    private var contentViewController: UIViewController?

    private var categoryCarousel: CategoriesCarouselViewController!
    private var disposables = Set<AnyCancellable>()
    private var utteranceCancellable: AnyCancellable?

    private let transcriptionOutputView = TranscriptionOutputTextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addLayoutGuide(contentLayoutGuide)

        outputLabel.accessibilityID = .root.outputText
        keyboardButton.accessibilityID = .shared.keyboardButton
        settingsButton.accessibilityID = .shared.settingsButton
        
        // Content layout guide
        NSLayoutConstraint.activate([
            contentLayoutGuide.topAnchor.constraint(equalTo: categoryCarousel.view.bottomAnchor),
            contentLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        updateOutputLabelText(nil)

        categoryCarousel.$categoryObjectID
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.categoryDidChange($0)
            }.store(in: &disposables)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryCarousel" {
            categoryCarousel = (segue.destination as? CategoriesCarouselViewController)!
            return
        }
        super.prepare(for: segue, sender: sender)
    }

    @IBAction private func settingsButtonSelected(_ sender: Any) {
        let navigationController = VocableNavigationController(rootViewController: SettingsViewController())
        self.present(navigationController, animated: true)
    }

    @IBAction private func keyboardButtonSelected(_ sender: Any) {
        let vc = TextEditorViewController()
        let context = NSPersistentContainer.shared.newBackgroundContext()
        vc.delegate = FreeResponseTextEditorConfigurationProvider(context: context)
        Analytics.shared.track(.keyboardOpened)
        present(vc, animated: true)
    }

    private func categoryDidChange(_ categoryID: NSManagedObjectID) {
        let category = NSPersistentContainer.shared.viewContext.object(with: categoryID) as! Category
        let viewController: UIViewController
        let utterancePublisher: PublishedValue<String?>.Publisher

        let destinationIsListeningMode: Bool
        if #available(iOS 14.0, *), category.identifier == Category.Identifier.listeningMode {
            destinationIsListeningMode = true
        } else {
            destinationIsListeningMode = false
        }

        if category.identifier == Category.Identifier.numPad {
            let vc = NumericCategoryContentViewController()
            utterancePublisher = vc.$lastUtterance
            viewController = vc
        } else if #available(iOS 14.0, *), destinationIsListeningMode {
            let vc = ListeningResponseViewController()
            vc.delegate = self
            utterancePublisher = vc.$lastUtterance
            viewController = vc
        } else {
            let vc = CategoryDetailViewController(category: category)
            utterancePublisher = vc.$lastUtterance
            viewController = vc
        }

        if !destinationIsListeningMode {
            // If the user navigates away from the listening response VC, ensure they won't
            // continue to see the transcription as it gives the impression dictation is still running
            // Selected responses, however, should persist as usual
            if #available(iOS 14.0, *), contentViewController is ListeningResponseViewController {
                if outputLabel.isHidden {
                    updateOutputLabelText(nil, isDictated: false)
                }
            }

            SpeechRecognitionController.shared.stopTranscribing()
        } else {
            SpeechRecognitionController.shared.startTranscribing()
        }

        utteranceCancellable = utterancePublisher.receive(on: DispatchQueue.main)
            .filter({!($0?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)})
            .sink { [weak self] newValue in
                self?.updateOutputLabelText(newValue, isDictated: false)
            }
        setContentViewController(viewController, animated: true)
    }

    private func setContentViewController(_ viewController: UIViewController?, animated: Bool) {

        let childrenToDisposeOf = children.filter {
            ![categoryCarousel, viewController].contains($0)
        }

        let contentTransform = CGAffineTransform.identity
        let transitionTransform = CGAffineTransform(translationX: 0,
                                                    y: contentLayoutGuide.layoutFrame.height)
        let contentAlpha: CGFloat = 1.0
        let transitionAlpha: CGFloat = 0.0

        func prepare() {
            if let viewController = viewController {
                installViewController(viewController, in: contentLayoutGuide)
                if animated {
                    viewController.view.transform = transitionTransform
                    viewController.view.alpha = transitionAlpha
                }
            }
        }

        func actions() {
            if let viewController = viewController {
                viewController.view.transform = contentTransform
                viewController.view.alpha = contentAlpha
            }
            for inactiveViewController in childrenToDisposeOf {
                inactiveViewController.view.transform = transitionTransform
                inactiveViewController.view.alpha = transitionAlpha
            }
        }

        func finalize(_ didFinish: Bool) {
            for inactiveViewController in childrenToDisposeOf {
                guard inactiveViewController.parent != nil else {
                    continue
                }

                inactiveViewController.willMove(toParent: nil)
                inactiveViewController.view.removeFromSuperview()
                inactiveViewController.removeFromParent()
            }

            self.contentViewController = viewController
        }

        prepare()
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1.0,
                       options: .beginFromCurrentState,
                       animations: actions,
                       completion: finalize)
    }

    private func installViewController(_ viewController: UIViewController, in layoutGuide: UILayoutGuide) {

        addChild(viewController)

        let viewToInsertBelow = view.subviews.first { categoryCarousel.view.isDescendant(of: $0) }
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.removeFromSuperview()
        view.insertSubview(viewController.view, belowSubview: viewToInsertBelow ?? view)

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        ])

        viewController.didMove(toParent: self)
    }

    private func setIsTranscriptionOutputHidden(_ isHidden: Bool, animated: Bool) {

        guard transcriptionOutputView.isHidden != isHidden else { return }

        func actions() {
            transcriptionOutputView.isHidden = isHidden
            outputLabel.isHidden = !isHidden
            if isHidden {
                outputAlignmentView.addSubview(outputLabel)
                outputLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    outputLabel.topAnchor.constraint(equalTo: outputAlignmentView.topAnchor),
                    outputLabel.leftAnchor.constraint(equalTo: outputAlignmentView.leftAnchor),
                    outputLabel.rightAnchor.constraint(equalTo: outputAlignmentView.rightAnchor),
                    outputLabel.bottomAnchor.constraint(equalTo: outputAlignmentView.bottomAnchor)
                ])
            } else {
                outputAlignmentView.addSubview(transcriptionOutputView)
                transcriptionOutputView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    transcriptionOutputView.topAnchor.constraint(equalTo: view.topAnchor),
                    transcriptionOutputView.leftAnchor.constraint(equalTo: outputAlignmentView.leftAnchor),
                    transcriptionOutputView.rightAnchor.constraint(equalTo: outputAlignmentView.rightAnchor),
                    transcriptionOutputView.bottomAnchor.constraint(equalTo: outputAlignmentView.bottomAnchor)
                ])
            }
        }

        func completion(_ didFinish: Bool) {
            guard didFinish else { return }
            if isHidden {
                transcriptionOutputView.text = "\n\n\n"
                transcriptionOutputView.removeFromSuperview()
            } else {
                outputLabel.removeFromSuperview()
            }
        }

        if animated {
            UIView.transition(with: self.view,
                              duration: 0.3,
                              options: .beginFromCurrentState,
                              animations: actions,
                              completion: completion)
        } else {
            actions()
            completion(true)
        }
    }

    private func updateOutputLabelText(_ text: String?, isDictated: Bool = false) {

        setIsTranscriptionOutputHidden(!isDictated, animated: true)

        func outputLabelPlaceholder() -> String {
            return String(localized: "main_screen.textfield_placeholder.default")
        }

        if isDictated {
            outputLabel.text = outputLabelPlaceholder()
            UIView.transition(with: transcriptionOutputView,
                              duration: 0.2,
                              options: [.transitionCrossDissolve, .beginFromCurrentState],
                              animations: { [weak self] in
                                self?.transcriptionOutputView.text = "\n\n\n" + (text ?? "")
                              }, completion: nil)
        } else {
            transcriptionOutputView.text = "\n\n\n"
            outputLabel.text = text ?? outputLabelPlaceholder()
        }
    }
    
    // MARK: Transcription Output Debug Gesture Handling

    @IBAction private func handleTranscriptionOutputDebugGesture(_ recognizer: UIGestureRecognizer?) {
        if #available(iOS 14.0, *) {
            let controller = UIHostingController(rootView: ListenModeDebugView())
            present(controller, animated: true, completion: nil)
        }
    }

    // MARK: ListeningResponseViewControllerDelegate

    func didUpdateSpeechResponse(_ text: String?) {
        updateOutputLabelText(text, isDictated: (text != nil))
    }

    func resetOutputText() {
        updateOutputLabelText(nil, isDictated: false)
    }

}
