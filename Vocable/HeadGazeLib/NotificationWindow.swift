//
//  NotificationWindow.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import ARKit
import Combine

class NotificationWindow: UIWindow {
    
    private weak var warningView: UIView?
    private weak var phraseSavedView: UIView?
    
    private var cancellables = Set<AnyCancellable>()
    weak var cursorView: UIVirtualCursorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        AppConfig.$isHeadTrackingEnabled.sink { [weak self] isEnabled in
            guard let self = self else { return }
            if isEnabled {
                self.installCursorViewIfNeeded()
            } else {
                self.cursorView?.removeFromSuperview()
                self.handleWarning(shouldDisplay: false)
            }
        }.store(in: &cancellables)
    }
    
    private func installCursorViewIfNeeded() {
        guard cursorView?.superview == nil else { return }

        let cursorView = UIVirtualCursorView()
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cursorView)

        NSLayoutConstraint.activate([
            cursorView.topAnchor.constraint(equalTo: topAnchor),
            cursorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cursorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cursorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.cursorView = cursorView
    }
    
    func handleWarning(shouldDisplay: Bool) {

        if warningView == nil {
            let warningView = UINib(nibName: "WarningView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
            warningView.alpha = 0
            self.warningView = warningView
            addSubview(warningView)
            warningView.translatesAutoresizingMaskIntoConstraints = false
            warningView.setContentHuggingPriority(.required, for: .horizontal)
            let horizontalPadding: CGFloat = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) ? 16 : 24
            NSLayoutConstraint.activate([
                warningView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                warningView.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: horizontalPadding),
                warningView.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: horizontalPadding),
                warningView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
            ])
        }
        self.isHidden = false
        let alphaValue = shouldDisplay ? 1.0 : 0.0
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
            self.warningView?.alpha = CGFloat(alphaValue)
        }, completion: { [weak self] didFinish in
            if didFinish && !shouldDisplay {
                self?.warningView?.removeFromSuperview()
                self?.isHidden = true
            }
        })
    }
    
    func handlePhraseSaved(toastLabelText: String) {
        if phraseSavedView == nil {
            let phraseSavedView = UINib(nibName: "ToastView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! ToastView
            phraseSavedView.alpha = 0
            phraseSavedView.text = toastLabelText
            self.phraseSavedView = phraseSavedView
            addSubview(phraseSavedView)
            phraseSavedView.translatesAutoresizingMaskIntoConstraints = false
            
            let horizontalPadding: CGFloat = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) ? 16 : 24
            NSLayoutConstraint.activate([
                phraseSavedView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                phraseSavedView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor,
                                                      constant: horizontalPadding),
                phraseSavedView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor,
                                                       constant: horizontalPadding),
                phraseSavedView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
                phraseSavedView.centerYAnchor.constraint(equalTo: centerYAnchor),
                phraseSavedView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }

         let fadeInOutDuration: TimeInterval = 0.5
         let presentationDuration: TimeInterval = 4
         self.isHidden = false

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
                                         self?.isHidden = true
                         })
         })
    }
}
