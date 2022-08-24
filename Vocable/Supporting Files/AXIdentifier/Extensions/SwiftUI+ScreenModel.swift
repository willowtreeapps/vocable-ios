//
//  SwiftUI+ScreenModel.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

private struct ScreenIdentityModifier: ViewModifier {

    let identifier: String

    func body(content: Content) -> some View {
        content.background(
            Color.clear
                .accessibilityIdentifier(identifier)
        )
    }
}

extension View {
    func prepareForAutomation(with modelType: any ScreenModel.Type) -> some View {
        self.modifier(ScreenIdentityModifier(identifier: modelType.screenIdentifier))
    }
}
