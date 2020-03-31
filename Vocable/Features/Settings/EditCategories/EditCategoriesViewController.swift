//
//  EditCategoriesViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import Combine

class EditCategoriesViewController: UIViewController {
    
    @IBOutlet weak var paginationView: PaginationView!
    
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
        
    }
    
    @IBAction func backToEditCategories(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
