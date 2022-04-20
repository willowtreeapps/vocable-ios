//
//  ListenModeDebugOptionsView.swift
//  Vocable
//
//  Created by Chris Stroud on 4/13/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

struct ListenModeDebugOptionsView: View {

    typealias UserDefaults = ListeningFeedbackUserDefaults

    @AppStorage(UserDefaults.showsHintText.key)
    var showsHintText = UserDefaults.showsHintText.defaultBoolValue
    @AppStorage(UserDefaults.hidesHintTextAfterSubmission.key)
    var hidesHintTextAfterFirstSubmission = UserDefaults.hidesHintTextAfterSubmission.defaultBoolValue
    @AppStorage(UserDefaults.disableShareUntilSubmitted.key)
    var disableShareUntilSubmitted = UserDefaults.disableShareUntilSubmitted.defaultBoolValue

    @AppStorage(UserDefaults.hintText.key)
    var hintText = UserDefaults.hintText.defaultStringValue
    @AppStorage(UserDefaults.submitButtonText.key)
    var submitButtonText = UserDefaults.submitButtonText.defaultStringValue
    @AppStorage(UserDefaults.submitConfirmationText.key)
    var submitConfirmationText = UserDefaults.submitConfirmationText.defaultStringValue

    var body: some View {
        Form {
            Section(header: Text("Hint Text")) {
                Toggle("Show Hint Text", isOn: $showsHintText)
                if showsHintText {
                    Toggle("Hide After First Submission", isOn: $hidesHintTextAfterFirstSubmission)
                }
            }
            Section(header: Text("Disable Share Button")) {
                Toggle("Enable Share Button After Submitting", isOn: $disableShareUntilSubmitted)
            }
            Section(header: Text("Customize Copy")) {
                if showsHintText {
                    HStack {
                        Text("Hint Label").frame(width: 135, alignment: .leading)
                        TextField("Hint Text", text: $hintText)
                    }
                }
                HStack {
                    Text("Submit Button").frame(width: 135, alignment: .leading)
                    TextField("Submit Button Text", text: $submitButtonText)
                }
                HStack {
                    Text("Confirmation Label").frame(width: 135, alignment: .leading)
                    TextField("Submit Confirmation Text", text: $submitConfirmationText)
                }
            }
        }
    }
}

struct AddPhraseCellBorderEditorContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListenModeDebugOptionsView()
    }
}
