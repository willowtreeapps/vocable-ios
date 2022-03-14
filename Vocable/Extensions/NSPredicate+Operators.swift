//
//  NSPredicate+Operators.swift
//  Vocable
//
//  Created by Chris Stroud on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension NSPredicate {

    public static func && (_ lhs: NSPredicate, _ rhs: NSPredicate) -> NSCompoundPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
    }

    public static func || (_ lhs: NSPredicate, _ rhs: NSPredicate) -> NSCompoundPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
    }

    public static prefix func ! (_ lhs: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(notPredicateWithSubpredicate: lhs)
    }

    public static func &= (_ lhs: inout NSPredicate, _ rhs: NSPredicate) {
        lhs = NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
    }

    public static func |= (_ lhs: inout NSPredicate, _ rhs: NSPredicate) {
        lhs = NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, rhs])
    }
}
