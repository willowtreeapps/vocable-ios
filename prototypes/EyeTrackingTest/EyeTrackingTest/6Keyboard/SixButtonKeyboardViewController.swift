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
    struct Constants {
        static let cornerRadius = CGFloat(5.0)
        static let borderWidth = CGFloat(3.0)
    }

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
    
    lazy var upperLeftHotCorner: HotCornerView = {
        let view = HotCornerView()
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0))
        view.alpha = 0.0
        return view
    }()
    
    lazy var upperRightHotCorner: HotCornerView = {
        let view = HotCornerView()
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0))
        view.alpha = 0.0
        return view
    }()
    
    lazy var lowerLeftHotCorner: HotCornerView = {
        let view = HotCornerView()
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0))
        view.alpha = 0.0
        return view
    }()
    
    lazy var lowerRightHotCorner: HotCornerView = {
        let view = HotCornerView()
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0))
        view.alpha = 0.0
        return view
    }()
    
    lazy var hotCornerGroup: TrackingGroup = TrackingGroup(widgets: [
        self.upperLeftHotCorner,
        self.upperRightHotCorner,
        self.lowerLeftHotCorner,
        self.lowerRightHotCorner]
    )
    

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
                 self.textfield, self.hotCornerGroup
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
        case .backspace:
            self.textExpression.backspace()
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
        self.view.backgroundColor = UIColor.appBackgroundColor
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
        
        self.adjustsFontSize()

        self.configureInitialState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.trackingEngine.applyToEach { trackingView in
            if let _ = trackingView as? HotCornerView {} else {
                trackingView.layer.cornerRadius = Constants.cornerRadius
                trackingView.clipsToBounds = true
                trackingView.layer.borderColor = UIColor.mainPageBorderColor.cgColor
                trackingView.layer.borderWidth = Constants.borderWidth
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let hotCorners = [self.upperLeftHotCorner, self.upperRightHotCorner, self.lowerLeftHotCorner, self.lowerRightHotCorner]
        hotCorners.forEach { view in
            view.alpha = 1.0
        }
        self.trackingEngine.enable()
        self.configureHotCornerCenters()
        
        let textBoxHeight = self.textfield.frame.height
        textfield.font = UIFont.systemFont(ofSize: textBoxHeight / 2.8)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let hotCorners = [self.upperLeftHotCorner, self.upperRightHotCorner, self.lowerLeftHotCorner, self.lowerRightHotCorner]
        hotCorners.forEach { view in
            view.alpha = 0.0
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            self.configureHotCornerCenters()
            hotCorners.forEach { view in
                view.alpha = 1.0
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let hotCorners = [self.upperLeftHotCorner, self.upperRightHotCorner, self.lowerLeftHotCorner, self.lowerRightHotCorner]
        hotCorners.forEach { view in
            view.alpha = 0.0
        }
        self.trackingEngine.disable()
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
        self.configureUI()
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
    
    func configureHotCornerCenters() {
        self.upperLeftHotCorner.center = CGPoint(x: 0.0, y: 0.0)
        self.upperRightHotCorner.center = CGPoint(x: self.view.bounds.maxX, y: 0.0)
        self.lowerLeftHotCorner.center = CGPoint(x: 0.0, y: self.view.bounds.maxY)
        self.lowerRightHotCorner.center = CGPoint(x: self.view.bounds.maxX, y: self.view.bounds.maxY)
    }
    
    func configureTextPredictiveState(for button: TrackingButton?, withValue value: String) {
        let isDisplayed = !value.isEmpty
        button?.alpha = isDisplayed ? 1.0 : 0.0
        button?.isUserInteractionEnabled = isDisplayed
        button?.isTrackingEnabled = isDisplayed
        button?.setTitle(value, for: .normal)
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
        
        self.upperLeftHotCorner.onGaze = { _ in
            print("Upper Left")
            self.perform(segue: .presetsSegue, sender: self)
        }
        
        self.upperRightHotCorner.onGaze = { _ in
            print("Upper Right")
        }
        
        self.lowerLeftHotCorner.onGaze = { _ in
            print("Lower Left")
        }
        
        self.lowerRightHotCorner.onGaze = { _ in
            print("Lower Right")
        }
    }
    
    func configureHoverStateColors() {
        self.backButton.animationViewColor = .backspaceButtonHoverColor
        self.clearButton.animationViewColor = .clearButtonHoverColor
        self.textfield.animationViewColor = .speakBoxHoverColer
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

extension SixButtonKeyboardViewController: TextExpressionDelegate {
    func textExpression(_ expression: TextExpression, valueChanged value: String) {
        DispatchQueue.main.async {
            self.textfield.text = expression.value
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
