//
//  String+Utilities.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/23/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.dropFirst()
    }
}
