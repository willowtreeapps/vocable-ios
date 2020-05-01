//
//  RootViewController.swift
//  Vocable AAC
//
//  Created by Steve Foster on 4/23/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable class RootViewController: VocableViewController {

    @IBOutlet private weak var outputLabel: UILabel!
    @IBOutlet private weak var keyboardButton: GazeableButton!
    @IBOutlet private weak var settingsButton: GazeableButton!

    private var categoryCarousel: CategoriesCarouselViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryCarousel" {
            categoryCarousel = (segue.destination as? CategoriesCarouselViewController)!
            return
        }
        super.prepare(for: segue, sender: sender)
    }

    @IBAction private func settingsButtonSelected(_ sender: Any) {
        let navigationController = VocableNavigationController(rootViewController: SettingsViewController())
        self.present(navigationController, animated: true)
    }

    @IBAction private func keyboardButtonSelected(_ sender: Any) {
        let vc = EditTextViewController()
        self.present(vc, animated: true)
    }

}
