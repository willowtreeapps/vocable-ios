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

class SixButtonKeyboardViewController: UIViewController, HotCornerTrackable {
    struct Constants {
        static let cornerRadius = CGFloat(5.0)
        static let borderWidth = CGFloat(3.0)
    }
    
    var component: HotCornerGazeableComponent?
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
    
    lazy var textExpression: TextExpression = {
        let expression = TextExpression()
        expression.delegate = self
        return expression
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
                 self.textfield
        ]
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
            self.textExpression.append(text: text)
        case .space:
            self.textExpression.space()
        case .back:
            break
        }
        self.configureKeys(with: self.keyViewOptions)
    }
    
    var topHalfWidgets: [HasTextComponent] {
        return [self.textPrediction1Button, self.textPrediction2Button,
                self.textPrediction3Button, self.textPrediction4Button,
                self.textPrediction5Button, self.textPrediction6Button,
                self.backButton, self.clearButton, self.textfield]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBackgroundColor
        
        self.adjustsFontSize()
        self.configureInitialState()
        self.backButton.setTitle("\u{2190} bksp", for: .normal)
        self.textfield.textContainerInset = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 0.0, right: 0.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.trackingEngine.applyToEach { trackingView in
            if let _ = trackingView as? HotCornerView {} else {
                trackingView.layer.cornerRadius = Constants.cornerRadius
                trackingView.clipsToBounds = true
                trackingView.layer.borderColor = UIColor.mainWidgetBorderColor.cgColor
                trackingView.layer.borderWidth = Constants.borderWidth
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let textBoxHeight = self.textfield.frame.height
        textfield.font = UIFont.systemFont(ofSize: textBoxHeight / 2.8)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.segueValue == .presetsSegue {
            // prepare the segue
        }
    }
    
    private func adjustsFontSize() {
        self.textPrediction1Button.titleLabel?.adjustsFontSizeToFitWidth = true
        self.textPrediction2Button.titleLabel?.adjustsFontSizeToFitWidth = true
        self.textPrediction3Button.titleLabel?.adjustsFontSizeToFitWidth = true
        self.textPrediction4Button.titleLabel?.adjustsFontSizeToFitWidth = true
        self.textPrediction5Button.titleLabel?.adjustsFontSizeToFitWidth = true
        self.textPrediction6Button.titleLabel?.adjustsFontSizeToFitWidth = true
        self.backButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.clearButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private func configureInitialState() {
        self.configureOnGazes()
        self.configureHoverStateColors()
        self.configureTextPredictiveState(for: self.textPrediction1Button, withValue: "")
        self.configureTextPredictiveState(for: self.textPrediction2Button, withValue: "")
        self.configureTextPredictiveState(for: self.textPrediction3Button, withValue: "")
        self.configureTextPredictiveState(for: self.textPrediction4Button, withValue: "")
        self.configureTextPredictiveState(for: self.textPrediction5Button, withValue: "")
        self.configureTextPredictiveState(for: self.textPrediction6Button, withValue: "")
        
        self.textPredictionTrackingGroup.isTrackingEnabled = false
        for view in self.interactiveViews {
            view.add(to: self.trackingEngine)
        }
        self.configureKeys(with: self.keyViewOptions)
    }
    
    func configureTextPredictiveState(for button: TrackingButton?, withValue value: String) {
        let isDisplayed = !value.isEmpty
        button?.alpha = isDisplayed ? 1.0 : 0.0
        button?.isUserInteractionEnabled = isDisplayed
        button?.isTrackingEnabled = isDisplayed
        button?.setTitle("\"\(value) \"", for: .normal)
    }
    
    func configureOnGazes() {
        self.backButton.onGaze = { _ in
            self.textExpression.backspace()
        }
        
        self.clearButton.onGaze = { _ in
            self.textExpression.clear()
        }
        
        self.textPredictionTrackingGroup.onGaze = { id in
            if let id = id {
                self.textPredictionController.updateExpression(withPredictionAt: id)
            }
        }
        
        self.textfield.onGaze = { _ in
            let speech = self.textExpression.value
            let utterance = AVSpeechUtterance(string: speech)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
        }
    }
    
    func configureHoverStateColors() {
        self.backButton.animationViewColor = .backspaceButtonHoverColor
        self.backButton.hoverBorderColor = .backspaceButtonHoverBorderColor
        self.clearButton.animationViewColor = .clearButtonHoverColor
        self.clearButton.hoverBorderColor = .clearButtonHoverBorderColor
        self.textfield.animationViewColor = .speakBoxHoverColor
        self.textfield.hoverBorderColor = .speakBoxHoverBorderColor
        self.topHalfWidgets.forEach { widget in
            widget.textComponentTextColor = .mainTextColor
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SixButtonKeyboardViewController: TextExpressionDelegate {
    func textExpression(_ expression: TextExpression, valueChanged value: String) {
        DispatchQueue.main.async {
            self.textfield.textComponentText = expression.value
            self.textPredictionController.updateState(withTextExpression: expression)
        }
    }
}

extension SixButtonKeyboardViewController: TextPredictionControllerDelegate {
    func textPredictionController(_ controller: TextPredictionController, didUpdatePrediction value: String, at index: Int) {
        DispatchQueue.main.async {
            let button = self.textPredictionTrackingGroup.widgets[safe: index] as? TrackingButton
            self.configureTextPredictiveState(for: button, withValue: value)
        }
    }
}
