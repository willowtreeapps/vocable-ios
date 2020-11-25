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
}

final class TrackingOnboardingViewController: VocableViewController {

    let leadingTop: GazeableButton = GazeableButton()
    let leadingBottom: GazeableButton  = GazeableButton()
    let trailingTop: GazeableButton = GazeableButton()
    let trailingBottom: GazeableButton = GazeableButton()

    // add a dismiss button in order to skip this onboarding exercise.

    override func viewDidLoad() {
        super.viewDidLoad()
        let buttons = [leadingTop, leadingBottom, trailingTop, trailingBottom]
        // Do any additional setup after loading the view.

        for (key, placement) in ButtonPlacement.allCases.enumerated() {
            let button = buttons[key]
            view.addSubview(button)
            commonInit(for: button)
            buttons[key].setTitle(placement.title, for: .normal)
            setButtonBackgrounds(button: button, placement: placement)
            setButtonConstraints(button: button, placement: placement)
        }
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

    @objc private func activatedButton() {
        print("Gazed upon the button.")
    }
}
