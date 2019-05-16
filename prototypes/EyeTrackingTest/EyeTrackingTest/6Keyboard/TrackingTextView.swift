//
//  TrackingTextView.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/17/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class TrackingTextView: UITextView, TrackableWidget, CircularAnimatable {
    struct Constants {
        static let animationSpeed = TimeInterval(1.0)
        static let cursorColor = UIColor.black
        static let startingCursorOrigin = CGPoint(x: 8, y: 0)
        static let cursorWidth = CGFloat(2.0)
        static let cursorDefaultHeight = CGFloat(16.0)
        static let cursorAnimationDuration = TimeInterval(0.5)
        static let cursorOffset = CGFloat(2.0)
    }
    var hoverBorderColor: UIColor?
    var isTrackingEnabled: Bool = true
    var animationSpeed = Constants.animationSpeed
    
    var animationViewColor: UIColor? {
        didSet {
            self.animationView.backgroundColor = self.animationViewColor
        }
    }
    
    override var text: String! {
        didSet {
            self.changeCursorPoint()
        }
    }
    
    var parent: TrackableWidget?
    var gazeableComponent = GazeableTrackingComponent()
    
    var id: Int?
    
    func add(to engine: TrackingEngine) {
        engine.registerView(self)
    }
    
    lazy var animationView: UIView = {
        let view = UIView()
        self.addSubview(view)
        self.sendSubviewToBack(view)
        view.backgroundColor = .animatingColor
        return view
    }()
    
    lazy var cursor: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: Constants.startingCursorOrigin, size: self.cursorSize)
        self.addSubview(view)
        return view
    }()
    
    var cursorSize: CGSize {
        let width = Constants.cursorWidth
        let height = self.font?.lineHeight ?? Constants.cursorDefaultHeight
        return CGSize(width: width, height: height)
    }
    
    func runCursor() {
        self.layer.removeAllAnimations()
        cursor.backgroundColor = Constants.cursorColor
        self.cursor.alpha = 1.0
        UIView.animate(withDuration: Constants.cursorAnimationDuration, delay: .zero, options: [.autoreverse, .repeat], animations: {
            self.cursor.alpha = 0.0
        }, completion: nil)
    }
    
    func changeCursorPoint() {
        if let range = self.selectedTextRange?.start {
            let position = self.offset(from: self.beginningOfDocument, to: range)
            print("Position: \(position)")
            let rect = self.caretRect(for: range)
            self.cursor.frame.size = self.cursorSize
            self.cursor.frame.origin = CGPoint(x: rect.origin.x + Constants.cursorOffset, y: rect.origin.y)
            print(rect)
        }
    }
}
