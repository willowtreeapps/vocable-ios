//
//  ListenModeDebugOptionsView.swift
//  Vocable
//
//  Created by Chris Stroud on 4/13/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

struct ListenModeDebugOptionsView: View {

    @AppStorage(ListeningFeedbackUserDefaultsKey.showsHintText) var showsHintText = false
    @AppStorage(ListeningFeedbackUserDefaultsKey.hidesHintTextAfterFirstSubmission) var hidesHintTextAfterFirstSubmission = false

    var body: some View {
        Form {
            Section(header: Text("Hint Text")) {
                Toggle("Show Hint Text", isOn: $showsHintText)
                Toggle("Hide after first submission", isOn: $hidesHintTextAfterFirstSubmission)
            }
        }
    }
}

struct AddPhraseCellBorderEditorContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListenModeDebugOptionsView()
    }
}
