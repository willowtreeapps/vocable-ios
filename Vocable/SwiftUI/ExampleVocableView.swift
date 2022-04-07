//
//  ExampleVocableView.swift
//  Vocable
//
//  Created by Robert Moyer on 4/4/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

struct ExampleVocableView: View {
    @State private var switchIsOn = false
    @State private var tapCount = 0

    var body: some View {
        VStack {
            Spacer().frame(height: 34)
            
            HStack {
                GazeButton { } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 25))
                        .frame(width: 30, height: 30)
                }
                Spacer()
                GazeButton { } label: {
                    Image(systemName: "keyboard")
                        .font(.system(size: 25))
                        .frame(width: 30, height: 30)
                }.disabled(true)
                GazeButton { } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 25))
                        .frame(width: 30, height: 30)
                }
            }

            Text("General")
                .padding()
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)

            VStack {
                GazeButton { } label: {
                    HStack {
                        Text("Rename Category")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                }

                GazeButton {
                    switchIsOn.toggle()
                } label: {
                    Toggle("Show Category", isOn: $switchIsOn)
                }

                GazeButton { } label: {
                    HStack {
                        Text("Edit Phrases")
                        Spacer()
                        Image(systemName: "chevron.forward")
                    }
                }

                GazeButton(role: .destructive) { } label: {
                    Label("Remove Category", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
            }
            .contentHuggingPriority(.defaultLow, axis: .horizontal)

            Spacer()

            GazeButton {
                tapCount += 1
            } label: {
                Text("Tap Count: \(tapCount)")
                    .fixedSize()
            }
        }
        .readableWidth()
        .padding()
        .gazeButtonStyle(.vocable)
        .background(Color(UIColor.primaryBackgroundColor).ignoresSafeArea())
    }
}

struct ExampleVocableView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleVocableView()
    }
}
