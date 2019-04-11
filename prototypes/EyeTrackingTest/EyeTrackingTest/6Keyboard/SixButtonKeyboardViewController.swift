//
//  6KeyboardViewController.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 10/24/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

class SixButtonKeyboardViewController: UIViewController, ScreenTrackingViewControllerDelegate {

    let trackingEngine = TrackingEngine()


    // MARK: - Outlets
    @IBOutlet var textfield: UITextField!

    @IBOutlet var backButton: TrackingButton!
    @IBOutlet var speakButton: TrackingButton!

    @IBOutlet var topLeftKey: KeyView!
    @IBOutlet var topCenterKey: KeyView!
    @IBOutlet var topRightKey: KeyView!
    @IBOutlet var bottomLeftKey: KeyView!
    @IBOutlet var bottomCenterKey: KeyView!
    @IBOutlet var bottomRightKey: KeyView!
    private var allKeyViews: [KeyView] {
        return [ self.topLeftKey,
                 self.topCenterKey,
                 self.topRightKey,
                 self.bottomLeftKey,
                 self.bottomCenterKey,
                 self.bottomRightKey ]
    }

    private var interactiveViews: [TrackingView] {
        return [ self.backButton, self.speakButton, self.topLeftKey, self.bottomLeftKey,
                 self.topCenterKey, self.bottomCenterKey, self.topRightKey, self.bottomRightKey ]
    }


    // MARK: - Key Options

    let keyViewValues: [KeyViewValue] = {
        var values: [KeyViewValue] = []

        let lowercaseLetters = UnicodeScalar("a").value...UnicodeScalar("z").value
        for scalar in lowercaseLetters {
            let letter = String(String.UnicodeScalarView([scalar].compactMap(UnicodeScalar.init)))
            values.append(.character(letter))
        }

        values.append(.space)
        values.append(.character("."))
        values.append(.character(","))
        values.append(.backspace)

        return values
    }()

    lazy var keyViewOptions: [KeyViewOptions] = {
        let optionGroups = self.keyViewValues.splitBy(subSize: 5)
        return optionGroups.enumerated().map { (offset, element) -> KeyViewOptions in
            var values: [KeyViewValue] = element
            
            // insert or pad
            if offset < values.count {
                values.insert(.back, at: offset)
            }
            while values.count < 6 {
                values.append(.back)
            }

            return KeyViewOptions(topLeft: values[safe: 0],
                                  topCenter: values[safe: 1],
                                  topRight: values[safe: 2],
                                  bottomLeft: values[safe: 3],
                                  bottomCenter: values[safe: 4],
                                  bottomRight: values[safe: 5])
        }
    }()

    private func configureKeys(with options: [KeyViewOptions]) {
        for pair in zip(options, self.allKeyViews) {
            pair.1.configure(with: .options(pair.0))
            pair.1.onGaze = {
                self.configureKeys(withSelectedOption: pair.0)
            }
        }
    }

    private func configureKeys(withSelectedOption option: KeyViewOptions) {
        for pair in zip(option.allValues, self.allKeyViews) {
            pair.1.configure(with: .value(pair.0))
            pair.1.onGaze = {
                self.didSelectValue(pair.0)
            }
        }
    }

    private func didSelectValue(_ keyValue: KeyViewValue) {
        print("selected: \(keyValue)")
        switch keyValue {
        case .character(let text):
            self.textfield.text?.append(contentsOf: text)
        case .space:
            self.textfield.text?.append(" ")
        case .backspace:
            if self.textfield.text?.isEmpty == false {
                _ = self.textfield.text?.removeLast()
            }
        case .back:
            break
        }

        self.configureKeys(with: self.keyViewOptions)
    }

    // MARK: - View Lifecycle

    let trackingView: UIView = UIView()
    lazy var screenTrackingViewController: ScreenTrackingViewController = {
        let vc = ScreenTrackingViewController()
        vc.delegate = self
        return vc
    }()

    func configureUI() {
        guard self.isViewLoaded else { return }

        self.screenTrackingViewController.showDebug = self.showDebug
        self.screenTrackingViewController.trackingConfiguration = self.trackingConfiguration
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.screenTrackingViewController.willMove(toParent: self)
        self.screenTrackingViewController.view.frame = self.view.bounds
        self.screenTrackingViewController.view.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.view.addSubview(self.screenTrackingViewController.view)
        self.addChild(self.screenTrackingViewController)
        self.screenTrackingViewController.didMove(toParent: self)

        trackingView.frame = CGRect(x: 0.0, y: 0.0, width: 40, height: 40)
        trackingView.layer.cornerRadius = 20.0
        trackingView.backgroundColor = UIColor.purple.withAlphaComponent(0.8)
        self.view.addSubview(trackingView)

        self.configureUI()

        self.backButton.onGaze = {
            self.navigationController?.popViewController(animated: true)
        }

        for view in self.interactiveViews {
            self.trackingEngine.registerView(view)
        }

        self.configureKeys(with: self.keyViewOptions)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        for interactive in interactiveViews {
            interactive.layer.cornerRadius = 8.0
            interactive.clipsToBounds = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - ScreenTrackingViewControllerDelegate

    func didUpdateTrackedPosition(_ trackedPositionOnScreen: CGPoint?, for screenTrackingViewController: ScreenTrackingViewController) {
        DispatchQueue.main.async {
            if let position = trackedPositionOnScreen {
                self.trackingView.isHidden = false

                let positionInView = self.view.convert(position, from: nil)
                self.trackingView.center = positionInView
                self.trackingEngine.updateWithTrackedPoint(position)
            } else {
                self.trackingView.isHidden = true
            }
        }
    }

    var showDebug: Bool = true {
        didSet {
            self.configureUI()
        }
    }

    var trackingConfiguration: TrackingConfiguration = .headTracking {
        didSet {
            self.configureUI()
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.showDebug = !self.showDebug
        }
    }

}
