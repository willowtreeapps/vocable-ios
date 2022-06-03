//
//  URL+Helpers.swift
//  Vocable
//
//  Created by Jesse Morgan on 6/2/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

extension UIApplication {

    static func openSettingsURL() {
        if let url = URL(string: self.openSettingsURLString) {
            if shared.canOpenURL(url) {
                shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
