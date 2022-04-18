//
//  XCUIElement.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/15/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    
    /// Waits the amount of time you specify for the element’s exists property to become true and then taps on it.
    ///
    /// Returns false if the timeout expires without the element coming into existence. In this case, the `tap` action
    /// will not occur.
    func waitForThenTap(timeout: TimeInterval = 0.25) -> Bool {
        let elementDidAppear = self.waitForExistence(timeout: timeout)
        if (elementDidAppear) {
            self.tap()
        }
        
        return elementDidAppear
    }
    
}
