//
//  GazeableAlertViewController.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class GazeEatingView: UIView {
    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        // Hit test this view's subviews, otherwise swallow the gazeable hit test
        super.gazeableHitTest(point, with: event) ?? self
    }
}

final class GazeableAlertViewController: UIViewController {

    static func make(_ confirmationAction: (() -> Void)? = nil) -> GazeableAlertViewController {
        let storyboard = UIStoryboard(name: "GazeableAlertViewController", bundle: nil)
        let alertViewController = storyboard.instantiateInitialViewController() as! GazeableAlertViewController
        alertViewController.confirmationAction = confirmationAction
        return alertViewController
    }

    private var confirmationAction: (() -> Void)?
    private var alertTitle: String? {
        didSet {
            updateDisplay()
        }
    }

    @IBOutlet private var borderContainerView: BorderedView!
    @IBOutlet private var alertTitleLabel: UILabel!
    @IBOutlet private var cancelButton: GazeableButton!
    @IBOutlet private var confirmButton: GazeableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelButton.backgroundView.roundedCorners = .bottomLeft
        confirmButton.backgroundView.roundedCorners = .bottomRight

        for button in [cancelButton, confirmButton] {
            guard let button = button else { continue }
            
            button.fillColor = .alertBackgroundColor
            button.selectionFillColor = .collectionViewBackgroundColor
            button.setTitleColor(.defaultTextColor, for: .selected)
            button.backgroundView.cornerRadius = 14
        }

        confirmButton.setTitleColor(.red, for: .normal)

        updateDisplay()
    }

    private func updateDisplay() {
        guard isViewLoaded else { return }

        alertTitleLabel.text = alertTitle
    }

    public func setAlertTitle(_ title: String) {
        self.alertTitle = title
    }

    @IBAction func didSelectCancelButton(_ sender: GazeableButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didSelectConfirmButton(_ sender: GazeableButton) {
        dismiss(animated: true) {
            self.confirmationAction?()
        }
    }

}
