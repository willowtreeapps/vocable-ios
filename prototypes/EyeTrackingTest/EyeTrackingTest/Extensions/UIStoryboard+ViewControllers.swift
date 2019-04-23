//
//  UIStoryboard+ViewControllers.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/23/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case main
    case hotCornersTracking
    case sixButtonKeyboardViewController
    case presets
    case unknown
    
    var name: String {
        return self.rawValue.capitalizeFirstLetter()
    }
}

extension UIStoryboard {
    static func get(storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.name, bundle: bundle)
    }
}

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension UIViewController: StoryboardIdentifiable {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static func get(from storyboard: Storyboard, bundle: Bundle? = nil) -> Self {
        return UIStoryboard.get(storyboard: storyboard, bundle: bundle).instantiateViewController(withIdentifier: Self.storyboardIdentifier) as! Self
    }
}
