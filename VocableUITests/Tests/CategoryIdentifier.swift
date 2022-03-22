//
//  CategoryIdentifiers.swift
//  Vocable
//
//  Created by Rudy Salas and Canan Arikan on 3/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

struct CategoryIdentifier {

    let identifier: String
    init(_ identifier: String) {
        self.identifier = identifier
    }
    
    static let mySayings = CategoryIdentifier("preset_user_favorites")
    static let recents = CategoryIdentifier("preset_user_recents")
    static let listen = CategoryIdentifier("preset_listening_mode")
    static let keyPad = CategoryIdentifier("preset_user_keypad")
    static let general = CategoryIdentifier("preset_C0B2A1A8-8333-4121-B4A8-FFFA185EB5D2")
    static let basicNeeds = CategoryIdentifier("preset_F8F5D1C9-0AA6-4152-BF7C-0851ACD1406B")
    static let personalCare = CategoryIdentifier("preset_E7ADBE88-2722-4DE7-BDC1-994F07EA294B")
    static let conversation = CategoryIdentifier("preset_EB7A9732-E28E-4440-A88B-BA2A1ACFBD76")
    static let environment = CategoryIdentifier("preset_52CA4E71-4A8C-4EA8-8EA8-C4B18AA16EC8")
    
}

struct CategoryTitleCellIdentifier {

    private let categoryIdentifier: CategoryIdentifier
    static let categoryTitleCellPrefix: String = "category_title_cell_"
    var identifier: String {
        CategoryTitleCellIdentifier.categoryTitleCellPrefix + categoryIdentifier.identifier
    }
    
    init?(_ identifier: String){
        if identifier.isEmpty{
            return nil
        }
        self.categoryIdentifier = CategoryIdentifier(identifier.replacingOccurrences(of: CategoryTitleCellIdentifier.categoryTitleCellPrefix, with: ""))
    }
    
    init(_ identifier: CategoryIdentifier) {
        self.categoryIdentifier = identifier
    }
    
}
