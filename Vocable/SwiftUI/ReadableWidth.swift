//
//  ReadableWidth.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

private struct ReadableWidth: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            content.frame(maxWidth: 672)
            Spacer(minLength: 0)
        }
    }
}

extension View {
    func readableWidth() -> some View {
        modifier(ReadableWidth())
    }
}

