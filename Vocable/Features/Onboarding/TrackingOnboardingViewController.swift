//
//  TrackingOnboardingViewController.swift
//  Vocable
//
//  Created by Joe Romero on 11/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Lottie

final class TrackingOnboardingViewController: VocableViewController {
    @IBOutlet weak var leadingTop: GazeableCornerButton!
    @IBOutlet weak var trailingTop: GazeableCornerButton!
    @IBOutlet weak var leadingBottom: GazeableCornerButton!
    @IBOutlet weak var trailingBottom: GazeableCornerButton!
    @IBOutlet weak var exitButton: GazeableButton!
    @IBOutlet weak var onboardingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var faceTrackingAnimation: AnimationView!

    var onboardingEngine = OnboardingEngine(OnboardingStep.testSteps)

    private var buttonDictionary: [ButtonPlacement: GazeableCornerButton] = [:]

    private var requiredCurrentStep: ButtonPlacement? = .leadingTop

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDictionary = [
            .leadingTop: leadingTop,
            .leadingBottom: leadingBottom,
            .trailingTop: trailingTop,
            .trailingBottom: trailingBottom
        ]

        faceTrackingAnimation.contentMode = .scaleAspectFit
        faceTrackingAnimation.loopMode = .loop
        faceTrackingAnimation.play()

        onboardingLabel.text = onboardingEngine.currentStep?.description
        titleLabel.text = onboardingEngine.currentStep?.title

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

    private func setButtonBackgrounds(button: GazeableCornerButton, placement: ButtonPlacement) {
        let quarterCircle = QuarterCircle(frame: CGRect(x: 0.0, y: 0.0, width: 175, height: 175)).asImage()
        let bgImage = quarterCircle.rotationFor(placement: placement)
        button.placement = placement
        button.setBackgroundImage(bgImage, for: .normal)
        button.setBackgroundImage(bgImage, for: .selected)
        button.setBackgroundImage(bgImage, for: .highlighted)
        button.clipsToBounds = false

    }

    @IBAction func skipTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cornerButtonTapped(_ sender: GazeableCornerButton) {
        guard requiredCurrentStep == sender.placement else {
            return
        }
        sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
        sender.removeCustomAnimations()
        setupNextButtonStep()
    }

    private func addAnimation(for placement: ButtonPlacement?) {
        guard let placement = placement, let button = buttonDictionary[placement] else {
            return
        }
        button.addArcAnimation(with: placement)
    }

    private func setupNextButtonStep() {
        guard onboardingEngine.currentStep?.placement != nil else {
            return
        }
        faceTrackingAnimation.isHidden = true

        if let step = onboardingEngine.nextStep() {
            requiredCurrentStep = step.placement
            addAnimation(for: step.placement)
            titleLabel.text = step.title
            onboardingLabel.text = step.description
            if step.placement == nil {
                exitButton.setTitle("Finish", for: .normal)
            }
        }
    }
}
