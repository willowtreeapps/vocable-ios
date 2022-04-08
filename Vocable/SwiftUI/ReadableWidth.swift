//
//  ReadableWidth.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

// Source: https://stackoverflow.com/a/68478487
private struct ReadableWidth: ViewModifier {
    @ScaledMetric(relativeTo: .body)
    private var pointSize: CGFloat = 20

    func body(content: Content) -> some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                content.frame(width: idealWidth(in: geo.size.width))
                Spacer(minLength: 0)
            }
        }
    }

    private func idealWidth(in containerWidth: CGFloat) -> CGFloat {
        // The internet seems to think the optimal readable width is 50-75
        // characters wide; I chose 70 here. The `pointSize` variable is the
        // approximate size of the system font and is wrapped in
        // @ScaledMetric to better support dynamic type. I assume that
        // the average character width is half of the size of the font.
        let idealWidth = 70 * pointSize / 2

        return containerWidth > idealWidth ? idealWidth : containerWidth
    }
}

extension View {
    func readableWidth() -> some View {
        modifier(ReadableWidth())
    }
}
