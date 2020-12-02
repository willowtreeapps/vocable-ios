//
//  TrackingOnboardingViewController.swift
//  Vocable
//
//  Created by Joe Romero on 11/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

enum ButtonPlacement: CaseIterable {
    case leadingTop
    case leadingBottom
    case trailingTop
    case trailingBottom

    var title: String {
        switch self {
        case .leadingTop:
            return "Top Left"
        case .leadingBottom:
            return "Bottom Left"
        case .trailingTop:
            return "Top Right"
        case .trailingBottom:
            return "Bottom Right"
        }
    }

    var clockwise: Bool {
        switch self {
        case .leadingTop, .trailingTop:
            return true
        case .leadingBottom, .trailingBottom:
            return false
        }
    }
}

final class TrackingOnboardingViewController: VocableViewController {

    let leadingTop: GazeableButton = GazeableButton()
    let leadingBottom: GazeableButton  = GazeableButton()
    let trailingTop: GazeableButton = GazeableButton()
    let trailingBottom: GazeableButton = GazeableButton()

    @IBOutlet weak var exitButton: GazeableButton!
    @IBOutlet weak var onboardingLabel: UILabel!
    var onboardingEngine = OnboardingEngine(OnboardingStep.testSteps)

    private var buttonDictionary: [ButtonPlacement: GazeableButton] = [:]

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
            view.addSubview(button)
            commonInit(for: button)
            button.setTitle(placement.title, for: .normal)
            setButtonBackgrounds(button: button, placement: placement)
            setButtonConstraints(button: button, placement: placement)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        addAnimation(for: onboardingEngine.currentStep?.placement)
    }

    private func commonInit(for button: GazeableButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        button.addTarget(self, action: #selector(activatedButton), for: .primaryActionTriggered)
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

    private func setButtonConstraints(button: GazeableButton, placement: ButtonPlacement) {
        var constraints: [NSLayoutConstraint] = []
        switch placement {
        case .leadingTop:
            constraints.append(button.leadingAnchor.constraint(equalTo: view.leadingAnchor))
            constraints.append(button.topAnchor.constraint(equalTo: view.topAnchor))
        case .leadingBottom:
            constraints.append(button.leadingAnchor.constraint(equalTo: view.leadingAnchor))
            constraints.append(button.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        case .trailingTop:
            constraints.append(button.trailingAnchor.constraint(equalTo: view.trailingAnchor))
            constraints.append(button.topAnchor.constraint(equalTo: view.topAnchor))
        case .trailingBottom:
            constraints.append(button.trailingAnchor.constraint(equalTo: view.trailingAnchor))
            constraints.append(button.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        }

        NSLayoutConstraint.activate(constraints + [
            button.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor)
        ])
    }

    private func addAnimation(for placement: ButtonPlacement?) {
        guard let placement = placement, let button = buttonDictionary[placement] else {
            return
        }
        button.addArcAnimation(with: placement)
    }

    @objc private func activatedButton() {
        guard onboardingEngine.currentStep?.placement != nil else {
            return
        }

        if let step = onboardingEngine.nextStep() {
            addAnimation(for: step.placement)

            UIView.transition(with: onboardingLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
                self.onboardingLabel.text = step.description
            }, completion: nil)

            if step.placement == nil {
                exitButton.setTitle("Finish", for: .normal)
            }
        }
    }
}
