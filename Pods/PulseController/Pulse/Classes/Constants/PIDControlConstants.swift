//
//  PulseConstants.swift
//  Pulse
//
//  Created by Dawid Cieslak on 15/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import Foundation


/// Configuration for tuning
enum PulseConstants: SingleControlDisplayable {
    
    case minimumValueStep
    case proportionalGain
    case integralGain
    case derivativeGain
    
    /// Name of control
    public var name: String {
        switch self {
        case .minimumValueStep:
            return "Minimum Value Step"
        case .proportionalGain:
            return "Proportional Gain"
        case .integralGain:
            return "Integral Gain"
        case .derivativeGain:
            return "Derivative Gain"
        }
    }
    
    /// Minimum value that can be set
    public var minimumValue: Float {
        switch self {
        case .minimumValueStep:
            return 0.003
        case .proportionalGain:
            return 1
        case .integralGain:
            return 0.1
        case .derivativeGain:
            return 0.1
        }
    }
    
    /// Maximum value that can be set
    public var maximumValue: Float {
        switch self {
        case .minimumValueStep:
            return 0.3
        case .proportionalGain:
            return 5
        case .integralGain:
            return 1
        case .derivativeGain:
            return 1
        }
    }
}

