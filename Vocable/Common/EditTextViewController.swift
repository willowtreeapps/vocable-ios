//
//  EditTextViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreData
import Combine

final class EditTextViewController: UIViewController, UICollectionViewDelegate {
    
    private var disposables = Set<AnyCancellable>()
    
    private var keyboardViewController: KeyboardViewController?
    
    var initialText: String = ""

    private var textHasChanged = false

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "KeyboardViewController" {
            keyboardViewController = segue.destination as? KeyboardViewController
        }
    }

    var editTextCompletionHandler: (String) -> Void = { (_) in
        assertionFailure("Completion not handled")
    }

    @IBOutlet var textView: OutputTextView!
    @IBOutlet private var confirmEditButton: GazeableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialAttributedText = NSAttributedString(string: initialText)
        keyboardViewController?.attributedText = initialAttributedText
        confirmEditButton.isEnabled = false
        keyboardViewController?.$attributedText.sink(receiveValue: { (attributedText) in
            self.textView.attributedText = attributedText
            let didTextChange = self.initialText != attributedText?.string

            let isTextEmpty = attributedText?.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
            self.textHasChanged = didTextChange
            self.confirmEditButton.isEnabled = didTextChange && !isTextEmpty
        }).store(in: &disposables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        if textHasChanged {
            handleDismissAlert()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func confirmEdit(_ sender: Any) {
        editTextCompletionHandler(textView.text ?? "")
        dismiss(animated: true, completion: nil)
    }
    
    private func handleDismissAlert() {
        func discardChangesAction() {
            dismiss(animated: true, completion: nil)
        }
        
        let title = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.title",
                                      comment: "Exit edit sayings alert title")
        let discardButtonTitle = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.button.discard.title",
                                                   comment: "Discard changes alert action title")
        let continueButtonTitle = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.button.continue_editing.title",
                                                    comment: "Continue editing alert action title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: discardButtonTitle, handler: discardChangesAction))
        alert.addAction(GazeableAlertAction(title: continueButtonTitle, style: .bold))
        self.present(alert, animated: true)
    }
    
}
