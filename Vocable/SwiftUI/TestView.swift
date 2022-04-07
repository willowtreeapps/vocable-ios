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
        VStack {
            Spacer().frame(height: 34)
            
            HStack {
                GazeButton { } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 25))
                        .frame(width: 60, height: 60)
                }
                Spacer()
                GazeButton { } label: {
                    Image(systemName: "keyboard")
                        .font(.system(size: 25))
                        .frame(width: 60, height: 60)
                }
                GazeButton { } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 25))
                        .frame(width: 60, height: 60)
                }
            }

            Spacer().frame(height: 40)

            VStack {
                GazeButton { } label: {
                    HStack {
                        Text("Rename Category")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .padding(20)
                }

                GazeButton {
                    switchIsOn.toggle()
                } label: {
                    Toggle("Show Category", isOn: $switchIsOn)
                        .padding()
                }

                GazeButton { } label: {
                    HStack {
                        Text("Edit Phrases")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                    .padding(20)
                }

                GazeButton(role: .destructive) { } label: {
                    Label("Remove Category", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                        .padding(20)
                }
            }
            .contentHuggingPriority(.defaultLow, axis: .horizontal)

            Spacer()

            GazeButton {
                tapCount += 1
            } label: {
                Text("Tap Count: \(tapCount)")
                    .padding(30)
                    .fixedSize()
            }
        }
        .padding()
        .gazeButtonStyle(.vocable)
        .background(Color(UIColor.primaryBackgroundColor).ignoresSafeArea())
    }
}

struct TestControlView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
