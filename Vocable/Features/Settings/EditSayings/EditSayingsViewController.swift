//
//  EditSayingsViewController.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

class EditSayingsViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var addButton: GazeableButton!
    @IBOutlet private var backButton: GazeableButton!
    
    @IBOutlet var paginationView: PaginationView!
    
    private var carouselCollectionViewController: CarouselGridCollectionViewController?
    private var disposables = Set<AnyCancellable>()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CarouselCollectionViewController" {
           carouselCollectionViewController = segue.destination as? CarouselGridCollectionViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carouselCollectionViewController?.progressPublisher.sink(receiveValue: { (pagingProgress) in
            guard let pagingProgress = pagingProgress else {
                return
            }
            if pagingProgress.pageCount > 1 {
                self.paginationView.setPaginationButtonsEnabled(true)
            } else {
                self.paginationView.setPaginationButtonsEnabled(false)
            }
            let computedPageCount = max(pagingProgress.pageCount, 1)

            self.paginationView.textLabel.text = String(format: NSLocalizedString("Page %d of %d", comment: ""), pagingProgress.pageIndex + 1, computedPageCount)
        }).store(in: &disposables)
        
        paginationView.nextPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToNextPage), for: .primaryActionTriggered)
        paginationView.previousPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToPreviousPage), for: .primaryActionTriggered)

        titleLabel.text = NSLocalizedString("My Sayings", comment: "Category: My Sayings")
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPhrasePressed(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "EditSaying") as? EditKeyboardViewController {
            show(vc, sender: nil)
        }
    }
}
