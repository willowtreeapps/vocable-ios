//
//  UIViewController+ScreenModel.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

extension UIViewController {

    func prepareForAutomation(with modelType: any ScreenModel.Type) {
        if let existingID = self.view.accessibilityIdentifier {
            assertionFailure("View already has an accessibilityIdentifier: \(existingID)")
            return
        }
        self.view.accessibilityIdentifier = modelType.screenIdentifier
    }
}
