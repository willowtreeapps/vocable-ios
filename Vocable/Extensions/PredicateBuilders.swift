//
//  NSComparisonPredicate+KeyPath.swift
//  Vocable
//
//  Created by Chris Stroud on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import CoreData

private typealias PredicateOperator = NSComparisonPredicate.Operator

/// Constructs an `NSPredicate` where the given `KeyPath` must equal `true`
///
/// - Parameter lhs: `KeyPath` with a `Bool`value that is used for comparison
/// - Returns: `NSPredicate`
func Predicate<A>(_ lhs: KeyPath<A, Bool>) -> NSPredicate {
    Predicate(lhs, equalTo: true)
}

/// Constructs an `NSPredicate` where the given `KeyPath` must equal the given value
///
/// - Parameters:
///   - lhs: `KeyPath` whose value must equal `rhs`
///   - rhs: value which `lhs` must equal
/// - Returns: `NSPredicate`
func Predicate<A, B>(_ lhs: KeyPath<A, B>, equalTo rhs: B) -> NSPredicate {
    Predicate(lhs, .equalTo, rhs)
}

/// Constructs an `NSPredicate` where the given `KeyPath` must not equal the given value
///
/// - Parameters:
///   - lhs: `KeyPath` whose value must not equal `rhs`
///   - rhs: value which `lhs` must not equal
/// - Returns: `NSPredicate`
func Predicate<A, B>(_ lhs: KeyPath<A, B>, notEqualTo rhs: B) -> NSPredicate {
    Predicate(lhs, .notEqualTo, rhs)
}

/// Constructs an `NSPredicate` where the given `KeyPath` is compared to the given value using the provided operation
///
/// - Parameters:
///   - lhs: `KeyPath` whose value must not equal `rhs`
///   - rhs: value which `lhs` will be compared against
///   - operation: the method of comparison
/// - Returns: `NSPredicate`
private func Predicate<A, B>(_ lhs: KeyPath<A, B>, _ operation: PredicateOperator, _ rhs: B) -> NSPredicate {
    let lhs = NSExpression(forKeyPath: lhs)
    let rhs = NSExpression(forConstantValue: rhs)
    return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: operation)
}

/// Constructs an `NSPredicate` where the given `KeyPath` must equal the given value
///
/// - Parameters:
///   - lhs: `KeyPath` whose value must equal `rhs`
///   - rhs: optional value which `lhs` must equal
/// - Returns: `NSPredicate`
func Predicate<A, B>(_ lhs: KeyPath<A, B?>, equalTo rhs: B?) -> NSPredicate {
    Predicate(lhs, .equalTo, rhs)
}

/// Constructs an `NSPredicate` where the given `KeyPath` must not equal the given value
///
/// - Parameters:
///   - lhs: `KeyPath` whose optional value must not equal `rhs`
///   - rhs: optional value which `lhs` must not equal
/// - Returns: `NSPredicate`
func Predicate<A, B>(_ lhs: KeyPath<A, B?>, notEqualTo rhs: B?) -> NSPredicate {
    Predicate(lhs, .notEqualTo, rhs)
}

/// Constructs an `NSPredicate` where the given `KeyPath` is compared to the given value using the provided operation
///
/// - Parameters:
///   - lhs: `KeyPath` whose optional value must not equal `rhs`
///   - rhs: optional value which `lhs` will be compared against
///   - operation: the method of comparison
/// - Returns: `NSPredicate`
private func Predicate<A, B>(_ lhs: KeyPath<A, B?>, _ operation: PredicateOperator, _ rhs: B?) -> NSPredicate {
    let lhs = NSExpression(forKeyPath: lhs)
    let rhs = NSExpression(forConstantValue: rhs)
    return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: operation)
}

/// Constructs an `NSPredicate` where the given `KeyPath` must  equal the given value. The `rawValue` of the rhs value is used for comparison.
///
/// - Parameters:
///   - lhs: `KeyPath` whose optional value must equal the raw value of `rhs`
///   - rhs: `RawRepresentable` value which `lhs` must equal
/// - Returns: `NSPredicate`
func Predicate<A, B: RawRepresentable, C>(_ lhs: KeyPath<A, C>, equalTo rhs: B) -> NSPredicate where B.RawValue == C {
    Predicate(lhs, .equalTo, rhs)
}

/// Constructs an `NSPredicate` where the given `KeyPath` must  equal the given value. The `rawValue` of the rhs value is used for comparison.
///
/// - Parameters:
///   - lhs: `KeyPath` whose optional value must equal the raw value of `rhs`
///   - rhs: optional `RawRepresentable` value which `lhs` must equal
/// - Returns: `NSPredicate`
func Predicate<A, B: RawRepresentable, C>(_ lhs: KeyPath<A, C?>, equalTo rhs: B?) -> NSPredicate where B.RawValue == C {
    Predicate(lhs, .equalTo, rhs)
}

/// Constructs an `NSPredicate` where the given `KeyPath` must  not equal the given value. The `rawValue` of the rhs value is used for comparison.
///
/// - Parameters:
///   - lhs: `KeyPath` whose value must equal the raw value of `rhs`
///   - rhs: `RawRepresentable` value which `lhs` must equal
/// - Returns: `NSPredicate`
func Predicate<A, B: RawRepresentable, C>(_ lhs: KeyPath<A, C>, notEqualTo rhs: B) -> NSPredicate where B.RawValue == C {
    Predicate(lhs, .notEqualTo, rhs)
}

/// Constructs an `NSPredicate` where the given `KeyPath` must not equal the given value. The `rawValue` of the rhs value is used for comparison.
///
/// - Parameters:
///   - lhs: `KeyPath` whose optional value must not equal `rhs`
///   - rhs: optional `RawRepresentable` value which `lhs` will be compared against
/// - Returns: `NSPredicate`
func Predicate<A, B: RawRepresentable, C>(_ lhs: KeyPath<A, C?>, notEqualTo rhs: B?) -> NSPredicate where B.RawValue == C {
    Predicate(lhs, .notEqualTo, rhs)
}

/// Constructs an `NSPredicate` where the given `KeyPath` is compared to the given `RawRepresentable`'s raw value using the provided operation
///
/// - Parameters:
///   - lhs: `KeyPath` whose value is compared against `rhs`
///   - rhs: `RawRepresentable` value which `lhs` will be compared against
///   - operation: the method of comparison
/// - Returns: `NSPredicate`
private func Predicate<A, B: RawRepresentable, C>(_ lhs: KeyPath<A, C>, _ operation: PredicateOperator, _ rhs: B) -> NSPredicate where B.RawValue == C {
    let lhs = NSExpression(forKeyPath: lhs)
    let rhs = NSExpression(forConstantValue: rhs.rawValue)
    return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: operation)
}

/// Constructs an `NSPredicate` where the given `KeyPath` is compared to the given `RawRepresentable`'s raw value using the provided operation
///
/// - Parameters:
///   - lhs: `KeyPath` whose optional value is compared against `rhs`
///   - rhs: optional `RawRepresentable` value which `lhs` will be compared against
///   - operation: the method of comparison
/// - Returns: `NSPredicate`
private func Predicate<A, B: RawRepresentable, C>(_ lhs: KeyPath<A, C?>, _ operation: PredicateOperator, _ rhs: B?) -> NSPredicate where B.RawValue == C {
    let lhs = NSExpression(forKeyPath: lhs)
    let rhs = NSExpression(forConstantValue: rhs?.rawValue)
    return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: operation)
}

/// Constructs an `NSPredicate` where the given `KeyPath` is compared to the given `Collection` using the provided operation
///
/// - Parameters:
///   - lhs: `KeyPath` whose value is compared against `rhs`
///   - rhs: `Collection` which `lhs` will be compared against
///   - operation: the method of comparison
/// - Returns: `NSPredicate`
private func Predicate<A, B, C: Collection>(_ lhs: KeyPath<A, B>, _ operation: PredicateOperator, _ rhs: C) -> NSPredicate where C.Element == B {
    let lhs = NSExpression(forKeyPath: lhs)
    let rhs = NSExpression(forConstantValue: rhs)
    return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: operation)
}

/// Constructs an `NSPredicate` where the given `KeyPath` is compared to the given `Collection` using the provided operation
///
/// - Parameters:
///   - lhs: `KeyPath` whose value is compared against `rhs`
///   - rhs: `Collection` which `lhs` will be compared against
///   - operation: the method of comparison
/// - Returns: `NSPredicate`
private func Predicate<A, B: NSFastEnumeration, C: NSObjectProtocol>(_ lhs: KeyPath<A, B?>, _ operation: PredicateOperator, _ rhs: C) -> NSPredicate {
    let lhs = NSExpression(forKeyPath: lhs)
    let rhs = NSExpression(forConstantValue: rhs)
    return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: operation)
}

/// Constructs an `NSPredicate` where the value at the given `KeyPath` must be contained in the provided `Collection`
///
/// - Parameters:
///   - lhs: `KeyPath` whose value must be contained by `rhs`
///   - rhs: `Collection` which must contain `lhs` to evaluate `true`
/// - Returns: `NSPredicate`
func Predicate<A, B, C: Collection>(_ lhs: KeyPath<A, B>, isContainedIn rhs: C) -> NSPredicate where C.Element == B {
    return Predicate(lhs, .in, rhs)
}

/// Constructs an `NSPredicate` where the string value at the given `KeyPath` must begin with the provided value
///
/// - Parameters:
///   - lhs: `KeyPath` whose value is must begin with `rhs`
///   - rhs: `String` which `lhs` must begin with
/// - Returns: `NSPredicate`
func Predicate<A>(_ lhs: KeyPath<A, String?>, beginsWith rhs: String) -> NSPredicate {
    return Predicate(lhs, .beginsWith, rhs)
}

/// Constructs an `NSPredicate` where the string value at the given `KeyPath` must match the provided value
///
/// - Parameters:
///   - lhs: `KeyPath` whose value is must match `rhs`
///   - rhs: `String` which `lhs` must match
/// - Returns: `NSPredicate`
func Predicate<A>(_ lhs: KeyPath<A, String?>, like rhs: String) -> NSPredicate {
    return Predicate(lhs, .like, rhs)
}

/// Constructs an `NSPredicate` where the objectID at the given `KeyPath` must match the provided value
///
/// - Parameters:
///   - lhs: `KeyPath` whose value is must match `rhs`
///   - rhs: `NSManagedObject` which `lhs` must match
/// - Returns: `NSPredicate`
func Predicate<A: NSManagedObject, B: NSManagedObject>(_ lhs: KeyPath<A, B?>, isEqual rhs: NSManagedObjectID) -> NSPredicate {
    let lhs = NSExpression(forKeyPath: lhs)
    let rhs = NSExpression(forConstantValue: rhs)
    return NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo)
}
