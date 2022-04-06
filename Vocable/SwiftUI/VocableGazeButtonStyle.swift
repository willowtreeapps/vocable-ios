//
//  VocableGazeButtonStyle.swift
//  Vocable
//
//  Created by Robert Moyer on 4/5/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

struct VocableGazeButtonStyle: GazeButtonStyle {
    func makeBody(_ configuration: Configuration) -> some View {
        _Body(configuration)
    }

    private struct _Body<Label: View>: View {
        @Environment(\.isEnabled)
        private var isEnabled

        @Binding var state: ButtonState

        var label: Label
        var buttonRole: ButtonRole?

        init(_ configuration: Configuration) where Configuration.Label == Label {
            self._state = configuration.state
            self.label = configuration.label
            self.buttonRole = configuration.role
        }

        var body: some View {
            let isHighlighted = state.contains(.highlighted)
            let isDisabled = !isEnabled
            let isSelected = state.contains(.selected)
            let shouldHighlight = isHighlighted && !isSelected

            let textColor = isSelected ? Color(UIColor.primaryBackgroundColor) : Color.white

            let fillColor = isSelected ?
                Color(UIColor.cellSelectionColor) :
                buttonRole == .destructive ?
                    Color(UIColor.errorRed) :
                    Color(UIColor.defaultCellBackgroundColor)

            if #available(iOS 15.0, *) {
                label
                    .font(.headline)
                    .foregroundColor(textColor)
                    .background(fillColor)
                    .opacity(shouldHighlight || isDisabled ? 0.5 : 1)
                    .cornerRadius(8)
                    .overlay {
                        if shouldHighlight {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.cellBorderHighlightColor), lineWidth: 4)
                        }
                    }
                    .scaleEffect(shouldHighlight ? 0.95 : 1)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

extension GazeButtonStyle where Self == VocableGazeButtonStyle {
    static var vocable: VocableGazeButtonStyle {
        VocableGazeButtonStyle()
    }
}
