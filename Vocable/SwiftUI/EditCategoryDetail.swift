//
//  EditCategoryDetail.swift
//  Vocable
//
//  Created by Robert Moyer on 4/4/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import CoreData
import SwiftUI

private func makeFetchRequest(_ categoryId: NSManagedObjectID) -> NSFetchRequest<Category> {
    let request = Category.fetchRequest()

    request.predicate = NSPredicate(format: "(SELF = %@)", categoryId)
    request.sortDescriptors = []
    request.fetchLimit = 1

    return request
}


/// A SwiftUI version of the Edit Category Detail screen
///
/// **WARNING** - This view is meant to be used as an example only, it should
/// not be used in production.
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
                GazeButton {
                    // TODO: Handle this action
                } label: {
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

                GazeButton {
                    // TODO: Handle this action
                } label: {
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
        .gazeableAlert(
            String(localized: "category_editor.alert.delete_category_confirmation.title"),
            isPresented: $showingDeleteAlert,
            actions: [
                .cancel(withTitle: String(localized: "category_editor.alert.delete_category_confirmation.button.cancel.title")
                ) {
                    withAnimation { showingDeleteAlert = false }
                },
                .delete(withTitle: String(localized: "category_editor.alert.delete_category_confirmation.button.remove.title")
                ) {
                    removeCategory()
                    withAnimation { showingDeleteAlert = false }
                    dismiss()
                }
            ]
        )

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
