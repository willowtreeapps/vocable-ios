//
//  ScreenModelNavigator.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

struct ScreenModelNavigator<Source: ScreenModel> {

    private func waitForScreenToExist(timeout duration: TimeInterval) -> Bool {
        XCUIApplication()
            .descendants(matching: .any)
            .matching(identifier: Source.screenIdentifier)
            .firstMatch
            .waitForExistence(timeout: duration)
    }

    func performNavigation<Destination: ScreenModel>(
        to destination: Destination.Type,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        actions: (Source.Type) -> Void
    ) -> ScreenModelNavigator<Destination> {
        self.performNavigation(file: file, line: line, actions: actions)
    }

    func performNavigation<Destination: ScreenModel>(
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        actions: (Source.Type) -> Void
    ) -> ScreenModelNavigator<Destination> {
        let sourceExists = waitForScreenToExist(timeout: timeout)
        XCTAssertTrue(sourceExists,
                      "Source screen not found: \(type(of: Source.self))",
                      file: file,
                      line: line)

        actions(Source.self) // Caller navigates to destination

        let navigator = ScreenModelNavigator<Destination>()
        let destinationExists = navigator.waitForScreenToExist(timeout: timeout)
        XCTAssertTrue(destinationExists,
                      "Destination screen not found: \(type(of: Destination.self))",
                      file: file,
                      line: line)
        return navigator
    }
}
