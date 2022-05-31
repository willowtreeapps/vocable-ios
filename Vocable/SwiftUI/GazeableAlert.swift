//
//  GazeableAlert.swift
//  Vocable
//
//  Created by Robert Moyer on 5/16/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

extension View {
    /// Presents a gazeable alert with a message and a set of actions
    ///
    /// - Parameters:
    ///   - message: The message to be displayed in the alert
    ///   - isPresented: A binding to the presented state of the alert
    ///   - actions: The list of actions the user can take
    func gazeableAlert(
        _ message: String,
        isPresented: Binding<Bool>,
        actions: [GazeableAlertAction]
    ) -> some View {
        overlay(
            GazeableAlert(
                message: message,
                isPresented: isPresented,
                actions: actions
            )
        )
    }
}

struct GazeableAlert: View {
    let message: String
    @Binding var isPresented: Bool
    let actions: [GazeableAlertAction]

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .gazeBlocking()
                    .transition(.opacity)

                GazeableAlertRepresentable(
                    message: message,
                    actions: actions
                )
                .edgesIgnoringSafeArea([])
                .transition(.scale)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Supporting Views

private struct GazeableAlertRepresentable: UIViewControllerRepresentable {
    let message: String
    let actions: [GazeableAlertAction]

    func makeUIViewController(context: Context) -> GazeableAlertViewController {
        let alertViewController = GazeableAlertViewController(alertTitle: message)
        actions.forEach {
            alertViewController.addAction($0, withAutomaticDismissal: false)
        }

        return alertViewController
    }

    func updateUIViewController(
        _ uiViewController: GazeableAlertViewController,
        context: Context
    ) { /* No op */ }
}

struct GazeableAlert_Previews: PreviewProvider {
    static var previews: some View {
        GazeableAlert(
            message: "This is an alert!",
            isPresented: .constant(true),
            actions: [
                .cancel(withTitle: "Cancel"),
                .delete(withTitle: "Delete")
            ]
        )
    }
}
