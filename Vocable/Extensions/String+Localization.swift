//
//  String+Localization.swift
//  Vocable
//
//  Created by Chris Stroud on 4/26/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

// Allows the new iOS 15 syntax/API to work on earlier iOS versions.
// Not guaranteed to have identical behavior, but has been tested enough
// to give confidence that it should work well enough for our purposes.
extension String {
    @available(iOS, obsoleted: 15.0, message: "Use String(localized keyAndValue:, table:, bundle:, locale:, comment:) instead")
    init(localized key: String, table: String? = nil, bundle: Bundle = .main, locale: Locale = .current, comment: StaticString? = nil) {
        self = bundle.localizedString(forKey: key, value: nil, table: table)
    }
}
