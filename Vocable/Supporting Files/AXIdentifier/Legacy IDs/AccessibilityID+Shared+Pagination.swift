//
//  AXElement+Shared+Pagination.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AXElement.shared {
    public enum pagination {
        public static let previousButton: AXElement = "shared-pagination-previous-button"
        public static let nextButton: AXElement = "shared-pagination-next-button"
        public static let pageLabel: AXElement = "shared-pagination-page-label"
    }
}
