//
//  ToastContainerViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class ToastContainerViewController: UIViewController {
    
    private weak var phraseSavedView: UIView?
    private weak var warningView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationWindow.shared.isHidden = false
    }
    
    func presentEphemeralToast() {
        
    }
    
    func presentPersistantToast() -> ToastView {
        return ToastView()
    }
    
    func handlePhraseSaved(toastLabelText: String) {
        NotificationWindow.shared.isHidden = false
        if phraseSavedView == nil {
            let phraseSavedView = UINib(nibName: "ToastView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! ToastView
            phraseSavedView.alpha = 0
            phraseSavedView.text = toastLabelText
            self.phraseSavedView = phraseSavedView
            view.addSubview(phraseSavedView)
            phraseSavedView.translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalPadding: CGFloat = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) ? 16 : 24
            NSLayoutConstraint.activate([
                phraseSavedView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
                phraseSavedView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor,
                                                      constant: horizontalPadding),
                phraseSavedView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor,
                                                       constant: horizontalPadding),
                phraseSavedView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
                phraseSavedView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                phraseSavedView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }

         let fadeInOutDuration: TimeInterval = 0.5
         let presentationDuration: TimeInterval = 4

         // Fade in
         UIView.animate(withDuration: fadeInOutDuration,
                        delay: 0,
                        options: [.beginFromCurrentState, .curveEaseIn],
                        animations: { self.phraseSavedView?.alpha = 1 },
                        completion: { [weak self] entranceDidFinish in

                         guard entranceDidFinish else { return }

                         // Fade out
                         UIView.animate(withDuration: fadeInOutDuration,
                                        delay: presentationDuration,
                                        options: [.beginFromCurrentState, .curveEaseOut],
                                        animations: { self?.phraseSavedView?.alpha = 0 },
                                        completion: { dismissalDidFinish in
                                         guard dismissalDidFinish else { return }
                                         self?.phraseSavedView?.removeFromSuperview()
                                        NotificationWindow.shared.isHidden = true
                         })
         })
    }
    
    func handleWarning(shouldDisplay: Bool) {
        if warningView == nil {
            let warningView = UINib(nibName: "WarningView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
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
        NotificationWindow.shared.isHidden = false
        let alphaValue = shouldDisplay ? 1.0 : 0.0
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
            self.warningView?.alpha = CGFloat(alphaValue)
        }, completion: { [weak self] didFinish in
            if didFinish && !shouldDisplay {
                self?.warningView?.removeFromSuperview()
                NotificationWindow.shared.isHidden = true
            }
        })
    }

}
