//
//  ButtonRole.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

/// A value that describes the purpose of a button.
@available(iOS, obsoleted: 15, message: "Please use the built-in SwiftUI.ButtonRole type.")
struct ButtonRole: Equatable {
    private let rawValue: String

    private init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// A role that indicates a button that cancels an operation.
    ///
    /// Use this role for a button that cancels the current operation.
    static let cancel = ButtonRole("cancel")

    /// A role that indicates a destructive button.
    ///
    /// Use this role for a button that deletes user data,
    /// or performs an irreversible operation. A destructive
    /// button signals by its appearance that the user should
    /// carefully consider whether to tap the button.
    static let destructive = ButtonRole("destructive")
}
