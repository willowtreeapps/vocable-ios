//
//  URL+Helpers.swift
//  Vocable
//
//  Created by Jesse Morgan on 6/2/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

extension URL {

    static func openSettingsURL() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
