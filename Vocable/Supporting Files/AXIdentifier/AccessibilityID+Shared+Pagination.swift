//
//  AccessibilityID+Shared+Pagination.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.shared {
    public struct pagination {
        public static let previousButton: AccessibilityID = "shared-pagination-previous-button"
        public static let nextButton: AccessibilityID = "shared-pagination-next-button"
        public static let pageLabel: AccessibilityID = "shared-pagination-page-label"
        private init() {}
    }
}
