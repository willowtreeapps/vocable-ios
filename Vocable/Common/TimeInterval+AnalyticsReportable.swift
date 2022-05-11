//
//  TimeInterval+AnalyticsReportable.swift
//  Vocable
//
//  Created by Jesse Morgan on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension TimeInterval: AnalyticsReportable {
    var analyticsDescription: String {
        "\(self)s"
    }
}
