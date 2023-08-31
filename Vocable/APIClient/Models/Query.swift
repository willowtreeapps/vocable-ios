//
//  Query.swift
//  Vocable
//
//  Created by Andrew Carter on 8/17/23.
//  Copyright © 2023 WillowTree. All rights reserved.
//

import Foundation

struct Query: Codable {
    let prompt: String
    let history: [Exchange]
}
