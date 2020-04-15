//
//  EditSayingsViewController.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import CoreData

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
            self.paginationView.setPaginationButtonsEnabled(pagingProgress.pageCount > 1)
            self.paginationView.textLabel.text = pagingProgress.localizedString
        }).store(in: &disposables)
        
        paginationView.nextPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToNextPage), for: .primaryActionTriggered)
        paginationView.previousPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToPreviousPage), for: .primaryActionTriggered)

        titleLabel.text = Category.userFavoritesCategoryName()
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPhrasePressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "EditSayings", bundle: nil).instantiateViewController(identifier: "EditSaying") as? EditSayingsKeyboardViewController {
            show(vc, sender: nil)
        }
    }
}
