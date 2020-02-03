//
//  PresetPageControl.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 1/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class PresetPageControlReusableView: UICollectionReusableView {
    
    @IBOutlet var pageControl: UIPageControl!
    
    func updatePageControl() {
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
    }
    
}
