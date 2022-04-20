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
    @AppStorage(ListeningFeedbackUserDefaultsKey.disableShareUntilSubmitted) var disableShareUntilSubmitted = false


    var body: some View {
        Form {
            Section(header: Text("Hint Text")) {
                Toggle("Show Hint Text", isOn: $showsHintText)
                Toggle("Hide hint text after first submission", isOn: $hidesHintTextAfterFirstSubmission)
                    .disabled(!showsHintText)
                Toggle("Disable share until first submission", isOn: $disableShareUntilSubmitted)
            }
        }
    }
}

struct AddPhraseCellBorderEditorContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListenModeDebugOptionsView()
    }
}
