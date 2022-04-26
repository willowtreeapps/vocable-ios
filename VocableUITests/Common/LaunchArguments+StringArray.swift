//
//  LaunchArguments+StringArray.swift
//  VocableUITests
//
//  Created by Jesse Morgan on 4/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension LaunchArguments {

    static subscript(_ args: LaunchArguments.Key...) -> [String] {
        return args.map(\.rawValue)
    }
}
