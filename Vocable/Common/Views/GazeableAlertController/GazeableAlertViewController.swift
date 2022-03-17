//
//  GazeableAlertViewController.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class GazeableAlertAction: NSObject {

    public enum Style {
        case bold
        case `default`
        case destructive
    }

    let title: String
    let style: Style
    let handler: (() -> Void)?
    fileprivate var defaultCompletion: (() -> Void)?

    init(title: String, style: Style = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    @objc fileprivate func performActions() {
        defaultCompletion?()
        handler?()
    }

}

private final class DividerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        backgroundColor = .grayDivider
        setContentCompressionResistancePriority(.init(999), for: .horizontal)
        setContentCompressionResistancePriority(.init(999), for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 1, height: 1)
    }

}

private final class GazeableAlertView: BorderedView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        roundedCorners = .allCorners
        cornerRadius = 14
        fillColor = .alertBackgroundColor
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
            return CGSize(width: 695 / 2, height: UIView.noIntrinsicMetric)
        }
        return CGSize(width: 695, height: UIView.noIntrinsicMetric)
    }

}

private final class GazeableAlertButton: GazeableButton {

    var style: GazeableAlertAction.Style = .default {
        didSet {
            switch style {
            case .bold, .destructive:
                if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
                    titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
                } else {
                    titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
                }

            case .default:
                if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
                    titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
                } else {
                    titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .regular)
                }
            }
            updateForCurrentTraitCollection()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    private func commonInit() {

        cornerRadius = 14
        titleLabel?.adjustsFontSizeToFitWidth = true
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        updateForCurrentTraitCollection()
    }

    private func updateForCurrentTraitCollection() {
        contentEdgeInsets = .init(top: 24, left: 24, bottom: 24, right: 24)

        setFillColor(.alertBackgroundColor, for: .normal)
        setFillColor(.primaryColor, for: .selected)

        if case .destructive = style {
            setTitleColor(.errorRed, for: .normal)
        } else {
            setTitleColor(.black, for: .normal)
        }

        setTitleColor(.white, for: .selected)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateForCurrentTraitCollection()
    }

}

final class GazeableAlertViewController: UIViewController, UIViewControllerTransitioningDelegate {

    private lazy var alertView: GazeableAlertView = {
        let view = GazeableAlertView()
        return view
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

        private lazy var titleContainerView: UIView = {
            let view = UIView()
            return view
        }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var actionButtonStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()

    private var actions = [GazeableAlertAction]() {
        didSet {
            updateButtonLayout()
        }
    }

    init(alertTitle: String) {
        super.init(nibName: nil, bundle: nil)

        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom

        self.messageLabel.text = alertTitle
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        updateContentForCurrentTraitCollection()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateContentForCurrentTraitCollection()
    }

    private func updateContentForCurrentTraitCollection() {
        if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
            messageLabel.font = .systemFont(ofSize: 15, weight: .regular)
            titleContainerView.layoutMargins = UIEdgeInsets(top: 20, left: 35, bottom: 20, right: 35)
        } else {
            messageLabel.font = .systemFont(ofSize: 34, weight: .regular)
            titleContainerView.layoutMargins = UIEdgeInsets(top: 40, left: 50, bottom: 40, right: 50)
        }
    }

    func addAction(_ action: GazeableAlertAction) {
        action.defaultCompletion = { [weak self] in
            self?.presentingViewController?.dismiss(animated: true)
        }

        actions.append(action)
    }

    private func setupViews() {

        let alertView = GazeableAlertView()
        alertView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertView)

        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        alertView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleContainerView)

        let dividerView = DividerView(frame: .zero)
        containerStackView.addArrangedSubview(dividerView)
        containerStackView.addArrangedSubview(actionButtonStackView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            alertView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            alertView.topAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor),
            alertView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: alertView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func updateButtonLayout() {

        for view in actionButtonStackView.arrangedSubviews {
            actionButtonStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        var firstButton: GazeableButton?

        actions.forEach { action in
            let button = GazeableAlertButton(frame: .zero)
            button.setTitle(action.title, for: .normal)
            button.cornerRadius = alertView.cornerRadius
            button.style = action.style
            button.shouldShrinkWhenTouched = false
            button.backgroundColor = .clear
            button.addTarget(action, action: #selector(GazeableAlertAction.performActions), for: .primaryActionTriggered)

            if actionButtonStackView.arrangedSubviews.isEmpty {
                firstButton = button
                actionButtonStackView.addArrangedSubview(button)
            } else {
                let separator = DividerView()
                actionButtonStackView.addArrangedSubview(separator)
                actionButtonStackView.addArrangedSubview(button)

                if actionButtonStackView.axis == .horizontal {
                    button.widthAnchor.constraint(equalTo: firstButton!.widthAnchor).isActive = true
                } else {
                    button.heightAnchor.constraint(equalTo: firstButton!.heightAnchor).isActive = true
                }
            }

            if actions.count > 2 {
                actionButtonStackView.axis = .vertical
            } else {
                actionButtonStackView.axis = .horizontal
            }
        }

        let buttons: [GazeableAlertButton] = actionButtonStackView.arrangedSubviews.compactMap {
            if let button = $0 as? GazeableAlertButton {
                button.roundedCorners = []
                return button
            }
            return nil
        }

        let firstAlertButton = buttons.first
        let lastAlertButton = buttons.last

        if actions.count < 3 {
            firstAlertButton?.roundedCorners.insert(.bottomLeft)
            lastAlertButton?.roundedCorners.insert(.bottomRight)
        } else {
            lastAlertButton?.roundedCorners.insert([.bottomLeft, .bottomRight])
        }
    }

    // MARK: UIViewControllerTransitioningDelegate

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return GazeableAlertViewControllerTransitionAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return GazeableAlertViewControllerTransitionAnimator(isForward: false)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return GazeableAlertPresentationController(presentedViewController: presented, presenting: presenting)
    }

}

private final class GazeableAlertViewControllerTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let isForward: Bool
    required init(isForward: Bool = true) {
        self.isForward = isForward
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let isForward = self.isForward

        guard let presentedViewController = transitionContext.viewController(forKey: isForward ? .to : .from)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let transform = CGAffineTransform.identity
        let alpha: CGFloat = isForward ? 1 : 0

        let presentedView = presentedViewController.view!

        if isForward {
            transitionContext.containerView.addSubview(presentedView)
            presentedView.frame = transitionContext.finalFrame(for: presentedViewController)
            presentedView.layoutIfNeeded()
            presentedView.alpha = 0
            presentedView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        } else {
            presentedView.alpha = 1
            presentedView.transform = .identity
        }

        func actions() {
            presentedView.transform = transform
            presentedView.alpha = alpha
        }

        let duration = transitionDuration(using: transitionContext)
        let delay = isForward ? duration * 0.5 : 0.1
        UIView.animate(withDuration: delay,
                       delay: 0,
                       options: [],
                       animations: {
        }, completion: nil)

        UIView.animate(withDuration: duration,
                       delay: isForward ? delay : 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1.4,
                       options: .beginFromCurrentState,
                       animations: actions,
                       completion: transitionContext.completeTransition)
    }
}
