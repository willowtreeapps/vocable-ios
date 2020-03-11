//
//  CategoryViewModel.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct CategoryViewModel: Hashable {
    var identifier: String
    var name: String
    
    init?(_ category: Category) {
        guard let identifier = category.identifier,
            let name = category.name else {
                return nil
        }
        
        self.identifier = identifier
        self.name = name
    }
}
