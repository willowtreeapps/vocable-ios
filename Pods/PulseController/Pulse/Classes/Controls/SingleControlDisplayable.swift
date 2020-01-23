//
//  SingleControlDisplayable.swift
//  Pulse
//
//  Created by Dawid Cieslak on 15/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

/// Data required to present Pulse's single configuration
protocol SingleControlDisplayable {
    
    /// Name of factor being controlled
    var name: String { get }
    
    /// Minimum value that can be set
    var minimumValue: Float { get }
    
    /// Maximum value that can be set
    var maximumValue: Float { get }
}

