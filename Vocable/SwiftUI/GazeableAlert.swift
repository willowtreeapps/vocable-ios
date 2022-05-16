//
//  GazeableAlert.swift
//  Vocable
//
//  Created by Robert Moyer on 5/16/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

extension View {
    func gazeableAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        actions: [GazeableAlertAction]
    ) -> some View {
        overlay(
            GazeableAlert(
                title: title,
                isPresented: isPresented,
                actions: actions
            )
        )
    }
}

struct GazeableAlert: View {
    let title: String
    @Binding var isPresented: Bool
    let actions: [GazeableAlertAction]

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .gazeBlocking()
                    .transition(.opacity)

                GazeableAlertRepresentable(
                    title: title,
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
    let title: String
    let actions: [GazeableAlertAction]

    func makeUIViewController(context: Context) -> GazeableAlertViewController {
        let alertViewController = GazeableAlertViewController(alertTitle: title)
        actions.forEach {
            alertViewController.addAction($0, withAutomaticDismissal: false)
        }

        return alertViewController
    }

    func updateUIViewController(_ uiViewController: GazeableAlertViewController, context: Context) { /* No op */ }
}

struct GazeableAlert_Previews: PreviewProvider {
    static var previews: some View {
        GazeableAlert(
            title: "This is an alert!",
            isPresented: .constant(true),
            actions: [
                .cancel(withTitle: "Cancel"),
                .delete(withTitle: "Delete")
            ]
        )
    }
}
