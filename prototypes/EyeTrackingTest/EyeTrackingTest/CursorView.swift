//
//  CursorView.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/25/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class CursorView: UIView {
    struct Constants {
        static let innerCircleDiameter = CGFloat(10.0)
        static let borderWidth = CGFloat(2.0)
    }
    
    private var constraintsQueue: [NSLayoutConstraint] = []
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = self.frame.height / 2.0
        }
    }
    
    lazy var innerCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: Constants.innerCircleDiameter).isActive = true
        view.widthAnchor.constraint(equalToConstant: Constants.innerCircleDiameter).isActive = true
        self.constraintsQueue.append(view.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        self.constraintsQueue.append(view.centerYAnchor.constraint(equalTo: self.centerYAnchor))
        view.backgroundColor = UIColor.mainTextColor
        view.layer.cornerRadius = Constants.innerCircleDiameter / 2.0
        view.clipsToBounds = true
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.layer.borderColor = UIColor.mainTextColor.cgColor
        self.layer.borderWidth = Constants.borderWidth
        self.addSubview(self.innerCircle)
        NSLayoutConstraint.activate(constraintsQueue)
    }
}
