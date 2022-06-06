//
//  View+.swift
//  Vocable
//
//  Created by Robert Moyer on 6/6/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

extension View {
    @available(iOS, obsoleted: 15, message: "Please use the built-in overlay modifier")
    func overlay<Content>(
        alignment: Alignment = .center,
        @ViewBuilder _ content: () -> Content
    ) -> some View where Content: View {
        overlay(content())
    }
}
