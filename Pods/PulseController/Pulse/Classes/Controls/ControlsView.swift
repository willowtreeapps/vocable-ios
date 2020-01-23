//
//  ControlsView.swift
//  Pulse
//
//  Created by Dawid Cieslak on 15/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

/// Providers multiple controllers to tune all major configuration factors
class ControlsView: UIView {
    
    /// Notifies about value `ControlsView`
    var configurationChanged: ((_ sender: ControlsView, _ newConfiguration: Pulse.Configuration) -> Void)?
    
    // UI Components
    
    /// Static values for UI components
    private struct LayoutConstants {
        
        // Spacing between items in stack views
        static let ContainerStackViewSpacing: CGFloat = 5.0
        
        /// Colors of graph's background gradinet
        static let GraphColors: [UIColor] = [UIColor(red: 72.0/255.0, green: 35.0/255.0, blue: 174.0/255.0, alpha: 1.0),
                                             UIColor(red: 184.0/255.0, green: 109.0/255.0, blue: 215.0/255.0, alpha: 1.0)]
    }
    
    /// Wraps all controls as vertical list
    private lazy var containerStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    // Controls for all configuration factors
    let minimumStepView: SingleControlView
    let proportionalGainView: SingleControlView
    let integralGainView: SingleControlView
    let derivativeGainView: SingleControlView
    let allControlViews: [SingleControlView]
    
    /// Wraps all controls
    private var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10.0
      //  view.layer.masksToBounds = true
        return view
    }()
    
    // Are constraints already set
    private var didSetConstraints = false
    
    /// Inits with presets
    ///
    /// - Parameters:
    ///   - initialConfiguration: Initial configuration to be displayed by scroll bars
    required init(initialConfiguration: Pulse.Configuration) {
        minimumStepView = SingleControlView(configuration: PulseConstants.minimumValueStep)
        proportionalGainView = SingleControlView(configuration: PulseConstants.proportionalGain)
        integralGainView = SingleControlView(configuration: PulseConstants.integralGain)
        derivativeGainView = SingleControlView(configuration: PulseConstants.derivativeGain)
        
        allControlViews = [minimumStepView, proportionalGainView, integralGainView, derivativeGainView]
        
        super.init(frame: .zero)
        
        updateControls(with: initialConfiguration)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(containerStackView)
        for controlView in allControlViews {
            controlView.translatesAutoresizingMaskIntoConstraints = false
            controlView.valueChanged = sliderValueChanged
            containerStackView.addArrangedSubview(controlView)
        }
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 4, height: 4)
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOpacity = 0.3
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        guard didSetConstraints == false else {
            return
        }
        
        didSetConstraints = true
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            
            containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            containerStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates control with new configuration
    ///
    /// - Parameter configuration: New configuration with values for each of Pulse factors
    private func updateControls(with configuration: Pulse.Configuration) {
        minimumStepView.value = Float(configuration.minimumValueStep)
        proportionalGainView.value = Float(configuration.Kp)
        derivativeGainView.value = Float(configuration.Kd)
        integralGainView.value = Float(configuration.Ki)
    }
}

// MARK: - ControlsView
extension ControlsView {
    
    /// Called when one of sliders changes value
    ///
    /// - Parameter sender: Slider being changed
    @objc func sliderValueChanged(sender: SingleControlView, newValue: Float) {
        let minimumStepValue = CGFloat(minimumStepView.value)
        let proportionalGainValue = CGFloat(proportionalGainView.value)
        let integralGain = CGFloat(integralGainView.value)
        let derivativeGain = CGFloat(derivativeGainView.value)
        
        let newConfiguration = Pulse.Configuration(minimumValueStep: minimumStepValue,
                                                      Kp: proportionalGainValue,
                                                      Ki: integralGain,
                                                      Kd: derivativeGain)
        // Notify about configuration being updated
        configurationChanged?(self, newConfiguration)
    }
}


