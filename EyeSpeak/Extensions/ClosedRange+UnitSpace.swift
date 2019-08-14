//
//  ClosedRange+UnitSpace.swift
//  EyeSpeak
//
//  Created by Duncan Lewis on 9/20/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

extension ClosedRange where Bound == Int {

    static var unitRange: ClosedRange {
        return 0...1
    }

}

extension ClosedRange where Bound == Float {

    static var unitRange: ClosedRange {
        return 0.0...1.0
    }

}

extension ClosedRange where Bound == Double {

    static var unitRange: ClosedRange {
        return 0.0...1.0
    }

}

extension ClosedRange where Bound == CGFloat {

    static var unitRange: ClosedRange {
        return 0.0...1.0
    }

}
