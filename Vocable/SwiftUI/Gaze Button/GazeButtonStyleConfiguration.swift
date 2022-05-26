//
//  GazeButtonStyleConfiguration.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

struct GazeButtonStyleConfiguration {
    struct Label: View {
        private var view: AnyView
        var body: some View { view }

        fileprivate init<V: View>(_ view: V) {
            self.view = AnyView(view)
        }
    }

    let state: Binding<ButtonState>
    let label: Label
    let role: ButtonRole?

    init<V: View>(label: V, state: Binding<ButtonState>, role: ButtonRole?) {
        self.label = Label(label)
        self.state = state
        self.role = role
    }
}
