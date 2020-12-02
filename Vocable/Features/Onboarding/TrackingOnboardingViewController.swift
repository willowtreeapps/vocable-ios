//
//  TrackingOnboardingViewController.swift
//  Vocable
//
//  Created by Joe Romero on 11/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class TrackingOnboardingViewController: VocableViewController {
    @IBOutlet weak var leadingTop: GazeableButton!
    @IBOutlet weak var trailingTop: GazeableButton!
    @IBOutlet weak var leadingBottom: GazeableButton!
    @IBOutlet weak var trailingBottom: GazeableButton!
    @IBOutlet weak var exitButton: GazeableButton!
    @IBOutlet weak var onboardingLabel: UILabel!

    var onboardingEngine = OnboardingEngine(OnboardingStep.testSteps)

    private var buttonDictionary: [ButtonPlacement: GazeableButton] = [:]

    private var requiredCurrentStep: ButtonPlacement? = .leadingTop

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDictionary = [
            .leadingTop: leadingTop,
            .leadingBottom: leadingBottom,
            .trailingTop: trailingTop,
            .trailingBottom: trailingBottom
        ]

        onboardingLabel.text = onboardingEngine.currentStep?.description

        for placement in ButtonPlacement.allCases {
            guard let button = buttonDictionary[placement] else {
                return
            }
            setButtonBackgrounds(button: button, placement: placement)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        addAnimation(for: onboardingEngine.currentStep?.placement)
    }

    private func setButtonBackgrounds(button: GazeableButton, placement: ButtonPlacement) {
        let quarterCircle = QuarterCircle(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 200)).asImage()
        let bgImage = quarterCircle.rotationFor(placement: placement)
        button.setBackgroundImage(bgImage, for: .normal)
        button.setBackgroundImage(bgImage, for: .selected)
        button.setBackgroundImage(bgImage, for: .highlighted)
        button.clipsToBounds = true
    }

    @IBAction func skipTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func leadingTopTapped(_ sender: UIButton) {
        guard requiredCurrentStep == .leadingTop else {
            return
        }
        sender.removeCustomAnimations()
        proceedToNextStep()
    }

    @IBAction func trailingTopTapped(_ sender: UIButton) {
        guard requiredCurrentStep == .trailingTop else {
            return
        }
        sender.removeCustomAnimations()
        proceedToNextStep()
    }

    @IBAction func leadingBottomTapped(_ sender: UIButton) {
        guard requiredCurrentStep == .leadingBottom else {
            return
        }
        sender.removeCustomAnimations()
        proceedToNextStep()
    }

    @IBAction func trailingBottomTapped(_ sender: UIButton) {
        guard requiredCurrentStep == .trailingBottom else {
            return
        }
        sender.removeCustomAnimations()
        proceedToNextStep()
    }

    private func addAnimation(for placement: ButtonPlacement?) {
        guard let placement = placement, let button = buttonDictionary[placement] else {
            return
        }
        button.addArcAnimation(with: placement)
    }

    private func proceedToNextStep() {
        guard onboardingEngine.currentStep?.placement != nil else {
            return
        }

        if let step = onboardingEngine.nextStep() {
            requiredCurrentStep = step.placement
            addAnimation(for: step.placement)

            UIView.transition(with: onboardingLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
                self.onboardingLabel.text = step.description
                if step.placement == nil {
                    self.exitButton.setTitle("Finish", for: .normal)
                }
            })

        }
    }
}
