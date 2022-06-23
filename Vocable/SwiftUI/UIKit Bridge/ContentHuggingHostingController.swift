//
//  ContentHuggingHostingController.swift
//  Vocable
//
//  Created by Robert Moyer on 4/6/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI
import UIKit

class ContentHuggingHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = view.intrinsicContentSize
    }
}
