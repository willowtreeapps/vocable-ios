//
//  OnboardingTracker.swift
//  Vocable
//
//  Created by Joe Romero on 11/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct OnboardingStep {
    let title: String?
    let description: String
    let placement: CornerPlacement?

    static let testSteps: [OnboardingStep] = [
        OnboardingStep(title: "Try out head-tracking!", description: "Slowly move your head until you can point the dot at the top left (TL) corner.", placement: .leadingTop),
        OnboardingStep(title: nil, description: "Now, move your head until you can point the dot at the bottom right (BR) corner.", placement: .trailingBottom),
        OnboardingStep(title: nil, description: "Great! Next try the top right (TR) corner button.", placement: .trailingTop),
        OnboardingStep(title: nil, description: "Last step, look at the bottom left (BL) corner button.", placement: .leadingBottom),
        OnboardingStep(title: "Good work!", description: "Use the finish button to exit.", placement: nil)
    ]
}

struct OnboardingTracker<T> {

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
