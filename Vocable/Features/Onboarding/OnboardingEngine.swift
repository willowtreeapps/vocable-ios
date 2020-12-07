//
//  OnboardingEngine.swift
//  Vocable
//
//  Created by Joe Romero on 11/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct OnboardingStep {
    let title: String?
    let description: String
    let placement: ButtonPlacement?

    static let testSteps: [OnboardingStep] = [
        OnboardingStep(title: "Let's learn how head-tracking works!", description: "Slowly move your head until you can point the dot at the top left corner.", placement: .leadingTop),
        OnboardingStep(title: nil, description: "Now, move your head until you can point the dot at the bottom right corner.", placement: .trailingBottom),
        OnboardingStep(title: nil, description: "Great! Next try the top right corner button.", placement: .trailingTop),
        OnboardingStep(title: nil, description: "Finally, look at the bottom left corner button.", placement: .leadingBottom),
        OnboardingStep(title: "Good work!", description: "Use the finish button to exit!", placement: nil)
    ]
}

struct OnboardingEngine<T> {

    private let steps: [T]
    private(set) var currentIndex: Int = 0

    init(_ steps: [T]) {
        self.steps = steps
    }

    // We hit the end of the steps array once we reach a nil return for the current step.
    var currentStep: T? {
        guard currentIndex < steps.count, currentIndex >= 0 else {
            return nil
        }
        return steps[currentIndex]
    }

    mutating func nextStep() -> T? {
        guard currentIndex < steps.count else {
            return nil
        }

        currentIndex += 1
        return steps[currentIndex]
    }
}
