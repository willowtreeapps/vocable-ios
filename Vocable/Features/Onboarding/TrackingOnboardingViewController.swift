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
    @IBOutlet weak var stepInfoContainerView: UIStackView!
    
    var onboardingEngine = OnboardingTracker(OnboardingStep.testSteps)

    private var buttonDictionary: [CornerPlacement: GazeableCornerButton] = [:]
    private var requiredCurrentStep: CornerPlacement?

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDictionary = [.leadingTop: leadingTop, .leadingBottom: leadingBottom, .trailingTop: trailingTop, .trailingBottom: trailingBottom]

        faceTrackingAnimation.contentMode = .scaleAspectFit
        faceTrackingAnimation.loopMode = .loop
        faceTrackingAnimation.play()

        onboardingLabel.text = onboardingEngine.currentStep?.description
        titleLabel.text = onboardingEngine.currentStep?.title
        requiredCurrentStep = onboardingEngine.currentStep?.placement

        for placement in CornerPlacement.allCases {
            guard let button = buttonDictionary[placement] else {
                return
            }
            button.placement = placement
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        addAnimation(for: onboardingEngine.currentStep?.placement)
    }

    @IBAction func skipTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cornerButtonTapped(_ button: GazeableCornerButton) {
        guard requiredCurrentStep == button.placement else {
            return
        }
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.removeCustomAnimations()
        startNextAvailableStep()
    }

    private func addAnimation(for placement: CornerPlacement?) {
        guard let placement = placement, let button = buttonDictionary[placement] else {
            return
        }
        button.addArcAnimation()
    }

    private func startNextAvailableStep() {
        guard onboardingEngine.currentStep?.placement != nil else {
            return
        }
        faceTrackingAnimation.isHidden = true

        if let step = onboardingEngine.nextStep() {
            requiredCurrentStep = step.placement
            addAnimation(for: step.placement)

            UIView.transition(with: stepInfoContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.titleLabel.text = step.title
                self.onboardingLabel.text = step.description
                if step.placement == nil {
                    self.exitButton.setTitle("Finish", for: .normal)
                }
            }, completion: nil)
        }
    }
}
