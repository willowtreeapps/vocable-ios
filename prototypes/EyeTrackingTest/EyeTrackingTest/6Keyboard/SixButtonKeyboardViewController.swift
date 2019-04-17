//
//  6KeyboardViewController.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 10/24/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML


class SixButtonKeyboardViewController: UIViewController {

    let trackingEngine = TrackingEngine()


    // MARK: - Outlets
    @IBOutlet var textfield: TrackingTextView!

    @IBOutlet var backButton: TrackingButton!
    @IBOutlet var clearButton: TrackingButton!
    
    @IBOutlet weak var textPrediction1Button: TrackingButton!
    @IBOutlet weak var textPrediction2Button: TrackingButton!
    @IBOutlet weak var textPrediction3Button: TrackingButton!
    @IBOutlet weak var textPrediction4Button: TrackingButton!
    @IBOutlet weak var textPrediction5Button: TrackingButton!
    @IBOutlet weak var textPrediction6Button: TrackingButton!
    
    lazy var textPredictionTrackingGroup = TrackingGroup(widgets: [
        self.textPrediction1Button,
        self.textPrediction2Button,
        self.textPrediction3Button,
        self.textPrediction4Button,
        self.textPrediction5Button,
        self.textPrediction6Button]
    )
    
    lazy var textPredictionController: TextPredictionController = {
        let controller = TextPredictionController()
        controller.delegate = self
        return controller
    }()
    

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

    private var interactiveViews: [TrackableWidget] {
        return [ self.backButton,
                 self.clearButton,
                 self.topLeftKey,
                 self.bottomLeftKey,
                 self.topCenterKey,
                 self.bottomCenterKey,
                 self.topRightKey,
                 self.bottomRightKey,
                 self.textPredictionTrackingGroup,
                 self.textfield]
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
            pair.1.onGaze = { _ in
                self.configureKeys(withSelectedOption: pair.0)
            }
        }
    }

    private func configureKeys(withSelectedOption option: KeyViewOptions) {
        for pair in zip(option.allValues, self.allKeyViews) {
            pair.1.configure(with: .value(pair.0))
            pair.1.onGaze = { _ in
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
        let newText = self.textfield.text ?? ""
        self.textPredictionController.updateState(newText: newText)
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

        self.configureInitialState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.trackingEngine.applyToEach { trackingView in
            trackingView.layer.cornerRadius = 8.0
            trackingView.clipsToBounds = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func configureInitialState() {
        self.configureUI()
        self.backButton.onGaze = { _ in
            self.navigationController?.popViewController(animated: true)
        }
        self.clearButton.onGaze = { _ in
            self.textPredictionController.updateState(newText: "")
        }
        self.textPredictionTrackingGroup.onGaze = { id in
            if let id = id {
                self.textPredictionController.updateExpression(withPredictionAt: id)
            }
        }
        self.textfield.onGaze = { _ in
            let speech = self.textfield.text ?? ""
            let utterance = AVSpeechUtterance(string: speech)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
        
        self.allKeyViews.forEach { keyView in
            keyView.shouldAnimate = true
        }
        self.backButton.shouldAnimate = true
        self.clearButton.shouldAnimate = true
        for view in self.interactiveViews {
            view.add(to: self.trackingEngine)
        }
        self.configureKeys(with: self.keyViewOptions)
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

extension SixButtonKeyboardViewController: ScreenTrackingViewControllerDelegate {
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
}

extension SixButtonKeyboardViewController: TextPredictionControllerDelegate {
    func textPredictionController(_ controller: TextPredictionController, didUpdatePrediction value: String, at index: Int) {
        DispatchQueue.main.async {
            let button = self.textPredictionTrackingGroup.widgets[safe: index] as? TrackingButton
            button?.shouldAnimate = !value.isEmpty
            button?.setTitle(value, for: .normal)
        }
    }
    
    func textPredictionController(_ controller: TextPredictionController, didUpdateExpression expression: TextExpression) {
        DispatchQueue.main.async {
            self.textfield.text = expression.expression
        }
    }
}
