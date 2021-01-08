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

@IBDesignable class RootViewController: VocableViewController, VoiceResponseViewControllerDelegate {

    @IBOutlet private weak var outputLabel: UILabel!
    @IBOutlet private weak var keyboardButton: GazeableButton!
    @IBOutlet private weak var settingsButton: GazeableButton!

    private let contentLayoutGuide = UILayoutGuide()
    private var contentViewController: UIViewController?

    private var categoryCarousel: CategoriesCarouselViewController!
    private var disposables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addLayoutGuide(contentLayoutGuide)

        outputLabel.accessibilityIdentifier = "root.outputTextLabel"
        keyboardButton.accessibilityIdentifier = "root.keyboardButton"
        settingsButton.accessibilityIdentifier = "root.settingsButton"
        
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
            .sink { self.categoryDidChange($0) }
            .store(in: &disposables)
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
        let vc = RootEditTextViewController()
        self.present(vc, animated: true)
    }

    private func categoryDidChange(_ categoryID: NSManagedObjectID) {
        let category = NSPersistentContainer.shared.viewContext.object(with: categoryID) as! Category
        let viewController: UIViewController
        let utterancePublisher: PublishedValue<String?>.Publisher
        if category.identifier == Category.Identifier.numPad {
            let vc = NumericCategoryContentViewController()
            utterancePublisher = vc.$lastUtterance
            viewController = vc
        } else if category.identifier == Category.Identifier.voice {
            let vc = VoiceResponseViewController()
            vc.delegate = self
            utterancePublisher = vc.$lastUtterance
            viewController = vc
        } else {
            let vc = CategoryDetailViewController(category: category)
            utterancePublisher = vc.$lastUtterance
            viewController = vc
        }
        utterancePublisher.receive(on: DispatchQueue.main)
            .filter({!($0?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)})
            .assign(to: \UILabel.text, on: outputLabel)
            .store(in: &disposables)
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
            for inactiveViewController in childrenToDisposeOf {                inactiveViewController.removeFromParent()
                inactiveViewController.view.removeFromSuperview()
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

    private func updateOutputLabelText(_ text: String?, isDictated: Bool = false) {
        outputLabel.text = text ?? NSLocalizedString("main_screen.textfield_placeholder.default",
                                                     comment: "Select something below to speak Hint Text")
        outputLabel.textColor = isDictated ? .cellSelectionColor : .defaultTextColor
    }

    // MARK: VoiceResponseViewControllerDelegate

    func didUpdateSpeechResponse(_ text: String?) {
        updateOutputLabelText(text, isDictated: (text != nil))
    }

}
