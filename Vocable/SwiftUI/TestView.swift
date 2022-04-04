//
//  TestView.swift
//  Vocable
//
//  Created by Robert Moyer on 4/4/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        ZStack {
            Color(UIColor.primaryBackgroundColor)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                GazeButton {
                    print("Button #1 pressed")
                } label: {
                    Text("Button #1")
                        .padding(30)
                }

                GazeButton {
                    print("settings pressed")
                } label: {
                    Image(systemName: "gear")
                        .font(.largeTitle)
                        .padding(20)
                }

                GazeButton {
                    print("info button pressed")
                } label: {
                    Label("More info", systemImage: "info.circle")
                        .padding(30)
                }
            }
            .gazeButtonStyle(.vocable)
        }
    }
}

struct TestControlView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
