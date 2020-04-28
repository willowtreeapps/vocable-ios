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
import CoreData

final class EditCategoriesViewController: UIViewController {
    
    @IBOutlet private var addCategoryButton: GazeableButton!
    @IBOutlet private var titleLabel: UILabel!
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
            self.pageNavigationView.setPaginationButtonsEnabled(pagingProgress.pageCount > 1)
            self.pageNavigationView.textLabel.text = pagingProgress.localizedString
        }).store(in: &disposables)
        
        addCategoryButton.isHidden = !AppConfig.showDebugOptions
        titleLabel.text = NSLocalizedString("categories_list_editor.header.title",
                                            comment: "Categories list editor screen header title")
        pageNavigationView.nextPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToNextPage), for: .primaryActionTriggered)
        pageNavigationView.previousPageButton.addTarget(carouselCollectionViewController, action: #selector(CarouselGridCollectionViewController.scrollToPreviousPage), for: .primaryActionTriggered)
        
    }
    
    @IBAction func backToEditCategories(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "EditTextViewController", bundle: nil).instantiateViewController(identifier: "EditTextViewController") as? EditTextViewController {
            vc.editTextCompletionHandler = { (newText) -> Void in
                let context = NSPersistentContainer.shared.viewContext

                _ = Category.create(withUserEntry: newText, in: context)
                do {
                    try Category.updateAllOrdinalValues(in: context)
                    try context.save()

                    let alertMessage = NSLocalizedString("category_editor.toast.successfully_saved.title", comment: "Saved to Categories")

                    ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
                } catch {
                    assertionFailure("Failed to save category: \(error)")
                }
            }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
}
