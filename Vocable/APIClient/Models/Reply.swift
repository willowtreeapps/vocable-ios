//
//  QueryResult.swift
//  Vocable
//
//  Created by Andrew Carter on 8/17/23.
//  Copyright © 2023 WillowTree. All rights reserved.
//

import Foundation

struct Reply: Decodable {
    let responses: [String]
    let history: [Exchange]
}
