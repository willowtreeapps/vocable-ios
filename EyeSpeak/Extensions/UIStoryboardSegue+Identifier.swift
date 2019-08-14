//
//  UIStoryboardSegue+Identifier.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

extension UIStoryboardSegue {
    var segueValue: Segue {
        return Segue(rawValue: self.identifier ?? "") ?? .unknown
    }
}
