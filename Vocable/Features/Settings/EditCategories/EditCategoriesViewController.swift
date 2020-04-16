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
    
    @IBOutlet private weak var pageNavigationView: PaginationView!
    
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
                self.pageNavigationView.setPaginationButtonsEnabled(true)
            } else {
                self.pageNavigationView.setPaginationButtonsEnabled(false)
            }
            let computedPageCount = max(pagingProgress.pageCount, 1)

            self.pageNavigationView.textLabel.text = String(format: NSLocalizedString("Page %d of %d", comment: ""), pagingProgress.pageIndex + 1, computedPageCount)
        }).store(in: &disposables)
        
        pageNavigationView.nextPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToNextPage), for: .primaryActionTriggered)
        pageNavigationView.previousPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToPreviousPage), for: .primaryActionTriggered)
        
    }
    
    @IBAction func backToEditCategories(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "EditTextViewController", bundle: nil).instantiateViewController(identifier: "EditTextViewController") as? EditTextViewController {
//            vc.isAddingCategory = true
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            return
        }
    }
    
}
