//
//  GazeBlocking.swift
//  Vocable
//
//  Created by Robert Moyer on 5/16/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

extension View {
    /// Prevents any gaze events from being passed to views beneath this one
    ///
    /// This can be useful when presenting a sheet or a full-screen cover on
    /// top of views that are capable of receiving gaze events.
    func gazeBlocking() -> some View {
        modifier(GazeBlocking())
    }
}

private struct GazeBlocking: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(EatGaze())
    }
}

/// A view that does not allow gazes to pass through it
private struct EatGaze: UIViewRepresentable {
    func makeUIView(context: Context) -> GazeEatingView {
        return GazeEatingView()
    }

    func updateUIView(
        _ uiView: GazeEatingView,
        context: Context
    ) { /* No op */ }
}
