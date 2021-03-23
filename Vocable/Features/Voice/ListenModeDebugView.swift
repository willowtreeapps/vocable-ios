//
//  ListenModeDebugView.swift
//  Vocable
//
//  Created by Chris Stroud on 3/19/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import SwiftUI
import VocableListenCore
import Foundation
import Combine

private struct Formatter {
    static let temporal: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .numeric
        return formatter
    }()

    static func count(from value: Int) -> String {
        if value == 0 {
            return "No Entries"
        }
        if value == 1 {
            return "1 Entry"
        }
        return "\(value) Entries"
    }
}

private struct ListenModeContextDetail: View {

    let context: VLLoggingContext

    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(context.entries.indices) { index in
                        VStack(alignment: .leading) {
                            Text("\(index + 1). \(context.entries[index].title)").bold().padding(.leading)
                            ScrollView(.horizontal, showsIndicators: false) {
                                context.entries[index].body.padding([.leading, .trailing])
                            }.frame(width: geo.frame(in: .global).width)
                        }
                    }
                }
            }
        }
        .navigationBarTitle(context.input)
        .navigationBarItems(trailing: Button(action: handleShareButton) {
            Image(systemName: "square.and.arrow.up")
        })
    }

    private func handleShareButton() {
        let data = context.description
        let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.presentedViewController?.present(activityVC, animated: true, completion: nil)
    }
}

@available(iOS 14.0, *)
private struct ListenModeDebugCell: View {

    let context: VLLoggingContext

    var body: some View {
        NavigationLink(destination: ListenModeContextDetail(context: context)) { [context] in
            VStack(alignment: .leading) {
                Text(context.input).font(.title2).foregroundColor(.primary)
                Text(Formatter.temporal.localizedString(for: context.startDate ?? Date(), relativeTo: Date())).font(.subheadline).foregroundColor(.secondary)
            }
        }
    }
}

@available(iOS 14.0, *)
struct ListenModeDebugView: View {

    @ObservedObject private var storage = ListenModeDebugStorage.shared

    @ViewBuilder
    private var listView: some View {
        if storage.contexts.isEmpty {
            VStack(spacing: 24) {
                Spacer()
                Text("No Entries").font(.title).bold()
                Text("The most recent listening sessions will be recorded here for easy debugging").font(.subheadline)
                Spacer()
            }.padding().padding()
        } else {
            List {
                Section {
                    ForEach(storage.contexts, id: \.self) {
                        ListenModeDebugCell(context: $0)
                    }.onDelete(perform: delete)
                }
                Section {
                    Button(action: clearEntries) {
                        HStack {
                            Spacer()
                            Text("Delete All").foregroundColor(.red).bold()
                            Spacer()
                        }
                    }
                }
            }.listStyle(InsetGroupedListStyle())
        }
    }

    @ViewBuilder
    private var toolbar: some View {
        if storage.contexts.isEmpty {
            EmptyView()
        } else {
            toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    Text(Formatter.count(from: storage.contexts.count))
                }
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            listView
            .navigationBarTitle("Sessions")
            toolbar
        }.navigationViewStyle(StackNavigationViewStyle())
    }

    private func clearEntries() {
        withAnimation {
            storage.contexts = []
        }
    }

    private func delete(at offsets: IndexSet) {
        storage.contexts.remove(atOffsets: offsets)
    }

}

@available(iOS 14.0, *)
struct ListenModeDebugView_Previews: PreviewProvider {
    static var previews: some View {
        ListenModeDebugView()
    }
}
