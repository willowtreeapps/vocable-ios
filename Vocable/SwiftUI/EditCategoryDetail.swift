//
//  ExampleVocableView.swift
//  Vocable
//
//  Created by Robert Moyer on 4/4/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import CoreData
import SwiftUI

struct GazeableAlert: UIViewControllerRepresentable {
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

private func makeFetchRequest(_ categoryId: NSManagedObjectID) -> NSFetchRequest<Category> {
    let request = Category.fetchRequest()

    request.predicate = NSPredicate(format: "(SELF = %@)", categoryId)
    request.sortDescriptors = []
    request.fetchLimit = 1

    return request
}

@available(iOS 15, *)
struct EditCategoryDetail: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FetchRequest private var results: FetchedResults<Category>
    @State private var showingDeleteAlert = false

    private var category: Category? { results.first }

    init(objectId: NSManagedObjectID) {
        self._results = FetchRequest(fetchRequest: makeFetchRequest(objectId))
    }

    // MARK: View Definition

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)
            
            HStack {
                GazeButton {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 34, weight: .bold))
                        .frame(width: 80)
                }
                Spacer()
            }

            Text(category?.name ?? "")
                .padding()
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                GazeButton(action: { }) {
                    HStack {
                        Text("Rename Category")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                }

                GazeButton(action: hideCategory) {
                    let binding = Binding {
                        !(category?.isHidden ?? true)
                    } set: { _ in
                        // No-op because this is handled with the button action
                    }

                    Toggle("Show Category", isOn: binding)
                }

                GazeButton(action: { }) {
                    HStack {
                        Text("Edit Phrases")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                }

                GazeButton(role: .destructive) {
                    withAnimation {
                        showingDeleteAlert = true
                    }
                } label: {
                    Label("Remove Category", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
            }
            .contentHuggingPriority(.defaultLow, axis: .horizontal)

            Spacer()
        }
        .padding(24)
        .gazeButtonStyle(.vocable)
        .navigationBarHidden(true)
        .background(Color(UIColor.primaryBackgroundColor).ignoresSafeArea())
        .overlay {
            if showingDeleteAlert { deleteAlert }
        }
    }

    // MARK: Alert View

    @ViewBuilder private var deleteAlert: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            GazeableAlert(
                title: NSLocalizedString(
                    "category_editor.alert.delete_category_confirmation.title",
                    comment: "Remove category alert title"),
                actions: [
                    .cancel(
                        withTitle: NSLocalizedString(
                            "category_editor.alert.delete_category_confirmation.button.cancel.title",
                            comment: "Cancel alert action title")
                    ) {
                        showingDeleteAlert = false
                    },
                    .delete(
                        withTitle: NSLocalizedString(
                            "category_editor.alert.delete_category_confirmation.button.remove.title",
                            comment: "Remove category alert action title")
                    ) {
                        removeCategory()
                        showingDeleteAlert = false
                        dismiss()
                    }
                ]
            )
        }
    }

    // MARK: Action handlers

    private func hideCategory() {
        guard let category = category else { return }

        let newState = !category.isHidden

        context.performAndWait {
            category.isHidden = newState
            try? Category.updateAllOrdinalValues(in: context)
            try? context.save()
        }
    }

    private func removeCategory() {
        context.perform {
            guard let category = category else { return }

            if category.isUserGenerated {
                context.delete(category)
            } else {
                category.isUserRemoved = true
            }

            try? Category.updateAllOrdinalValues(in: context)
            try? context.save()
        }
    }
}
