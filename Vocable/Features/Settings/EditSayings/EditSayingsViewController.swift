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
        if let vc = UIStoryboard(name: "EditTextViewController", bundle: nil).instantiateViewController(identifier: "EditTextViewController") as? EditTextViewController {
            vc.editTextCompletionHandler = { (newText) -> Void in
                let context = NSPersistentContainer.shared.viewContext

                _ = Phrase.create(withUserEntry: newText, in: context)
                do {
                    try context.save()

                    let alertMessage: String = {
                        let format = NSLocalizedString("phrase_editor.toast.successfully_saved_to_favorites.title_format", comment: "Saved to user favorites category toast title")
                        let categoryName = Category.userFavoritesCategoryName()
                        return String.localizedStringWithFormat(format, categoryName)
                    }()
                    
                    ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
                } catch {
                    assertionFailure("Failed to save user generated phrase: \(error)")
                }
            }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
