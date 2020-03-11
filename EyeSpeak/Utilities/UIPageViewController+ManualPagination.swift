//
//  UIPageViewController+ManualPagination.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

extension UIPageViewController {
    
    /// A convenience method for setting the next or previous view controller to be displayed
    func page(_ direction: UIPageViewController.NavigationDirection) {
        switch direction {
        case .forward:
            pageForward()
        case .reverse:
            pageBackward()
        @unknown default:
            pageForward()
        }
    }
    
    private func pageForward() {
        guard let currentViewController = viewControllers?.first,
            let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else {
                return
        }
        
        setViewControllers([nextViewController], direction: .forward, animated: true)
    }
    
    private func pageBackward() {
        guard let currentViewController = viewControllers?.first,
            let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else {
                return
        }
        
        setViewControllers([previousViewController], direction: .reverse, animated: true)
    }
}
