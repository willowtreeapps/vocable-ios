//
//  TestView.swift
//  Vocable
//
//  Created by Robert Moyer on 4/4/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

struct TestView: View {
    @State private var switchIsOn = false
    @State private var tapCount = 0

    var body: some View {
        ZStack {
            Color(UIColor.primaryBackgroundColor)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if switchIsOn {
                    Label("Lights on!", systemImage: "lightbulb.fill")
                        .foregroundColor(.white)
                } else {
                    Label("Lights off", systemImage: "lightbulb.slash.fill")
                        .foregroundColor(.white)
                }

                HStack(spacing: 30) {
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
                    }.disabled(true)

                    GazeButton {
                        print("info button pressed")
                    } label: {
                        Label("More info", systemImage: "info.circle")
                            .padding(30)
                    }
                }

                HStack {
                    GazeButton(role: .destructive) {
                        print("remove button pressed")
                    } label: {
                        Label("Remove Item", systemImage: "trash")
                            .padding(30)
                    }

                    GazeButton {
                        switchIsOn.toggle()
                    } label: {
                        Toggle("Lights", isOn: $switchIsOn)
                            .padding(30)
                    }

                    GazeButton {
                        tapCount += 1
                    } label: {
                        Text("Tap count: \(tapCount)")
                            .lineLimit(1)
                            .padding(30)
                    }
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
