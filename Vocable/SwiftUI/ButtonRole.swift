//
//  ButtonRole.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

@available(iOS, obsoleted: 15, message: "Please use the built-in SwiftUI.ButtonRole type.")
struct ButtonRole: Equatable {
    private let rawValue: String

    private init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    static let cancel = ButtonRole("cancel")
    static let destructive = ButtonRole("destructive")
}
