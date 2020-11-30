//
//  OnboardingEngine.swift
//  Vocable
//
//  Created by Joe Romero on 11/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct OnboardingStep {
    let description: String
    let placement: ButtonPlacement?

    static let testSteps: [OnboardingStep] = [
        OnboardingStep(description: "Let's learn how head-tracking works! Slowly move your head until you can point the dot at the top left corner.", placement: .leadingTop),
        OnboardingStep(description: "Now, move your head until you can point the dot at the bottom right corner.", placement: .trailingBottom),
        OnboardingStep(description: "Great! Next try the top right corner.", placement: .trailingTop),
        OnboardingStep(description: "Finish by looking at the bottom left corner.", placement: .leadingBottom),
        OnboardingStep(description: "Good work, use the finish button to exit!", placement: nil)
    ]
}

struct OnboardingEngine {

    private let steps: [OnboardingStep]
    private(set) var currentIndex: Int = 0

    // We hit the end of the steps array once we reach a nil return for the current step.
    var currentStep: OnboardingStep? {
        guard currentIndex < steps.count, currentIndex >= 0 else {
            return nil
        }
        return steps[currentIndex]
    }

    init(_ steps: [OnboardingStep]) {
        self.steps = steps
    }

    mutating func nextStep() {
        guard currentIndex < steps.count else {
            return
        }

        currentIndex += 1
    }
}
