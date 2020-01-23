//
//  SingleControlView.swift
//  Pulse
//
//  Created by Dawid Cieslak on 15/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import Foundation
import UIKit

/// Provides set of components to adjust single Pulse configuration factor
class SingleControlView: UIView {
    
    // Value changed closure
    var valueChanged: ((_ sender: SingleControlView, _ newValue: Float) -> Void)?
    
    /// Static values for UI components
    private struct LayoutConstants {
        
        /// Top and Bottom margins
        static let TopBottomMargin: CGFloat = 3.0
        
        /// Leading margin for label displaying current value
        static let ValueLabelLeadingMargin: CGFloat = 10.0
    }
    
    // UI Components
    // Titles
    private  var nameLabel: UILabel = {
        let font = UIFont(name: "AvenirNext-Bold", size: 12.5)
        let label = UILabel(frame: .zero)
        label.font = font
        return label
    }()
    
    private let valueLabel: UILabel = {
        let font = UIFont(name: "AvenirNext-Bold", size: 12.5)
        let label = UILabel(frame: .zero)
        label.font = font
        return label
    }()
    
    // Allows to control current current gain value
    private lazy var valueSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = UIColor(red: 42.0/255.0, green: 89.0/255.0, blue: 174.0/255.0, alpha: 1.0)
        slider.isContinuous = true
        return slider
    }()
    
    /// Current value
    var value: Float {
        set {
            update(newValue: newValue)
        }
        get {
            return valueSlider.value
        }
    }
    
    // Are constraints already set
    private var didSetConstraints: Bool = false
    
    /// Initial configuration
    private let configuration: SingleControlDisplayable
    
    required init(configuration: SingleControlDisplayable) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        valueSlider.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views
        addSubview(nameLabel)
        addSubview(valueSlider)
        addSubview(valueLabel)
        
        // Set listener to value change
        valueSlider.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
        update(with: configuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        guard didSetConstraints == false else {
            return
        }
        
        didSetConstraints = true
        
        // Setup constraints
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            valueSlider.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            valueSlider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            valueLabel.centerYAnchor.constraint(equalTo: valueSlider.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        let valueLabelLeadingConstraint = valueLabel.leadingAnchor.constraint(equalTo: valueSlider.trailingAnchor)
        valueLabelLeadingConstraint.priority = .defaultLow
        valueLabelLeadingConstraint.constant = LayoutConstants.ValueLabelLeadingMargin
        valueLabelLeadingConstraint.isActive = true
        
        let nameLabelTopConstraint =  nameLabel.topAnchor.constraint(equalTo: self.topAnchor)
        nameLabelTopConstraint.priority = .defaultHigh
        nameLabelTopConstraint.constant = LayoutConstants.TopBottomMargin
        nameLabelTopConstraint.isActive = true
        
        let valueSliderBottomConstraint = valueSlider.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        valueSliderBottomConstraint.priority = .defaultHigh
        valueSliderBottomConstraint.constant = -LayoutConstants.TopBottomMargin
        valueSliderBottomConstraint.isActive = true
    }
    
    /// Adjusts UI components with provided details
    ///
    /// - Parameter configuration: Object storing configuration details for UI components
    private func update(with configuration: SingleControlDisplayable) {
        nameLabel.text = configuration.name
        valueSlider.minimumValue = configuration.minimumValue
        valueSlider.maximumValue = configuration.maximumValue
    }
    
    /// Updates UI components with given value
    private func update(newValue: Float) {
        // Update slider value with animation
        valueSlider.value = newValue
        
        // Update displayed value
        displayGainValue(value)
    }
    
    /// Displays current gain value with custom formatting
    ///
    /// - Parameter value: Value to be displayed
    func displayGainValue(_ value: Float) {
        
        // Format string with rounded value with 3 digits
        let roundedNSNumber = NSNumber(value: value)
        valueLabel.text = Formatter.decimalFormat(fractionDigits: 3).string(from: roundedNSNumber)
    }
}

// MARK: - UISlider events
extension SingleControlView {
    @objc func valueChanged(sender: UISlider) {
        
        // Round value to 3 fraction places
        let roundedValue: Float = round(sender.value * 1000) / 1000
        
        // Notify listener
        valueChanged?(self, roundedValue)
        
        // Update displayed value
        displayGainValue(roundedValue)
    }
}
