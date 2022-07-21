//
//  Utilities.swift
//  VocableUITests
//
//  Created by Canan Arikan on 6/23/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

class Utilities {
    
    static func restartApp() {
        XCUIApplication().terminate()
        XCUIApplication().activate()
    }
    
    static func restartApp(withLaunchArguments launchArguments: Arguments) {
        let app = XCUIApplication()
        app.configure {
            launchArguments
        }
        app.terminate()
        app.activate()
    }
   
}
