//
//  EditSayingsViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

class EditSayingsViewController: UIViewController {

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
            if pagingProgress.pageCount <= 1 {
                self.paginationView.disablePaginationButtons()
            } else {
                self.paginationView.enablePaginationButtons()
            }
            let computedPageCount = pagingProgress.pageCount < 1 ? 1 : pagingProgress.pageCount
            self.paginationView.textLabel.text = "\(pagingProgress.pageIndex + 1) of \(computedPageCount)"
        }).store(in: &disposables)
        
        paginationView.nextPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToNextPage), for: .primaryActionTriggered)
        paginationView.previousPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToPreviousPage), for: .primaryActionTriggered)
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
