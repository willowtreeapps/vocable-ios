//
//  ContentHuggingPriority.swift
//  Vocable
//
//  Created by Robert Moyer on 4/6/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI
import UIKit

extension EnvironmentValues {
    private struct HorizontalContentHuggingPriorityKey: EnvironmentKey {
        static var defaultValue: UILayoutPriority = .defaultHigh
    }

    private struct VerticalContentHuggingPriorityKey: EnvironmentKey {
        static var defaultValue: UILayoutPriority = .defaultHigh
    }

    /// The priority with which a view associated with this
    /// environment resists being made larger than its intrinsic
    /// content size in the horizontal direction.
    ///
    /// The default value is `.defaultHigh`.
    var horizontalContentHuggingPriority: UILayoutPriority {
        get { self[HorizontalContentHuggingPriorityKey.self] }
        set { self[HorizontalContentHuggingPriorityKey.self] = newValue }
    }

    /// The priority with which a view associated with this
    /// environment resists being made larger than its intrinsic
    /// content size in the vertical direction.
    ///
    /// The default value is `.defaultHigh`.
    var verticalContentHuggingPriority: UILayoutPriority {
        get { self[VerticalContentHuggingPriorityKey.self] }
        set { self[VerticalContentHuggingPriorityKey.self] = newValue }
    }
}

extension View {
    /// Sets the content hugging priority for this view on the specified axis.
    ///
    /// - Parameters:
    ///   - priority: The new priority.
    ///   - axis: The axis for which the content hugging priority should be set.
    /// - Returns: A view that resists being made larger than its intrinsic content size, with the given priority level.
    @ViewBuilder func contentHuggingPriority(
        _ priority: UILayoutPriority,
        axis: NSLayoutConstraint.Axis
    ) -> some View {
        switch axis {
        case .vertical:
            environment(\.verticalContentHuggingPriority, priority)
        case .horizontal:
            environment(\.horizontalContentHuggingPriority, priority)
        @unknown default:
            self
        }
    }
}
