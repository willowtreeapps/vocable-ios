//
//  GazeableAlertViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class GazeEatingView: UIView {
    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        // Hit test this view's subviews, otherwise swallow the gazeable hit test
        super.gazeableHitTest(point, with: event) ?? self
    }
}

class GazeableAlertViewController: UIViewController {
    static func make(_ confirmationAction: (() -> Void)? = nil) -> GazeableAlertViewController {
        let storyboard = UIStoryboard(name: "GazeableAlertViewController", bundle: nil)
        let alertViewController = storyboard.instantiateInitialViewController() as! GazeableAlertViewController
        alertViewController.confirmationAction = confirmationAction
        return alertViewController
    }
    
    @IBOutlet weak var cancelButton: GazeableButton!
    @IBOutlet weak var confirmButton: GazeableButton!
    
    var confirmationAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for button in [cancelButton, confirmButton] {
            guard let button = button else { continue }
            
            button.fillColor = .alertBackgroundColor
            button.selectionFillColor = .collectionViewBackgroundColor
            button.setTitleColor(.defaultTextColor, for: .selected)
        }
    }
 
    @IBAction func didSelectCancelButton(_ sender: GazeableButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didSelectConfirmButton(_ sender: GazeableButton) {
        confirmationAction?()
        dismiss(animated: true)
    }
}
