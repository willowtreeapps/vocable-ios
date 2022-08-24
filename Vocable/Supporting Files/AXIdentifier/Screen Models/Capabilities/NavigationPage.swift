//
//  NavigationPage.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

// In Vocable, this is a page that is embedded in a
// VocableNavigationController. Could be used for
// standard navigation titles in other apps.
//
// By allowing pages to conform to this protocol, we
// aren't relying on class inheritance to be a dumping
// ground for shared behaviors. Screens can choose
// specifically what they need to opt into.
protocol NavigationPage { }
extension NavigationPage {
    var navigationTitle: AXElement {
        "shared-navigation-title"
    }
}
