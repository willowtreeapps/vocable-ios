//
//  ToastContainerViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class ToastContainerViewController: UIViewController {
    private var isToastWarningVisible = false
    private var headTrackingLostText: String?
    
    private weak var phraseSavedView: UIView? {
        didSet {
            updateWindowVisibility()
        }
    }

    private weak var warningView: UIView? {
        didSet {
            updateWindowVisibility()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWindowVisibility()
    }
    
    private func updateWindowVisibility() {
        if phraseSavedView == nil && warningView == nil {
            ToastWindow.shared.isHidden = true
        } else {
            ToastWindow.shared.isHidden = false
        }
    }
    
    // In the future we should get away from manipulating the window here.
    func handlePhraseSaved(toastLabelText: String) {
        if phraseSavedView == nil {
            let phraseSavedView = UINib(nibName: "ToastView", bundle: .main)
                .instantiate(withOwner: nil, options: nil).first as! ToastView
            phraseSavedView.alpha = 0
            phraseSavedView.text = toastLabelText
            view.addSubview(phraseSavedView)
            phraseSavedView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                phraseSavedView.widthAnchor.constraint(lessThanOrEqualTo: view.readableContentGuide.widthAnchor, multiplier: 0.9),
                phraseSavedView.heightAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.heightAnchor),
                phraseSavedView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                phraseSavedView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])

            self.phraseSavedView = phraseSavedView
        }

        let fadeInOutDuration: TimeInterval = 0.5
        let presentationDuration: TimeInterval = 4

        // Fade in
        UIView.animate(
            withDuration: fadeInOutDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseIn],
            animations: { self.phraseSavedView?.alpha = 1 },
            completion: { [weak self] entranceDidFinish in

                guard entranceDidFinish else { return }

                // Fade out
                UIView.animate(
                    withDuration: fadeInOutDuration,
                    delay: presentationDuration,
                    options: [.beginFromCurrentState, .curveEaseOut],
                    animations: { self?.phraseSavedView?.alpha = 0 },
                    completion: { dismissalDidFinish in
                        guard dismissalDidFinish else { return }
                        self?.phraseSavedView?.removeFromSuperview()
                    })
            })
    }
    
    func handleWarning(with title: String?, shouldDisplay: Bool) {
        if warningView == nil {
            let warningView = UINib(nibName: "WarningView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! WarningView
            warningView.label?.text = title
            warningView.alpha = 0
            self.warningView = warningView
            view.addSubview(warningView)
            warningView.translatesAutoresizingMaskIntoConstraints = false
            warningView.setContentHuggingPriority(.required, for: .horizontal)
            let horizontalPadding: CGFloat = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) ? 16 : 24
            NSLayoutConstraint.activate([
                warningView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                warningView.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: horizontalPadding),
                warningView.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: horizontalPadding),
                warningView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ])
        }
        if headTrackingLostText != nil && headTrackingLostText == title {
            return
        }
        self.headTrackingLostText = title
        let alphaValue = shouldDisplay ? 1.0 : 0.0
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
            self.warningView?.alpha = CGFloat(alphaValue)
        }, completion: { [weak self] didFinish in
            if didFinish && !shouldDisplay {
                self?.warningView?.removeFromSuperview()
                self?.headTrackingLostText = nil
            }
        })
    }

}
