//
//  SettingsViewController.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UICollectionViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet private var headerView: UINavigationItem!
    
    private weak var composeVC: MFMailComposeViewController?
    
    enum SettingsItem: CaseIterable {
        case privacyPolicy
        case contactDevs
        case versionNum
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupCollectionView()
    }
    
    func setupNavigationBar() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .collectionViewBackgroundColor
        let textAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.defaultTextColor, .font: UIFont.systemFont(ofSize: 34, weight: .bold)]
        barAppearance.largeTitleTextAttributes = textAttr
        self.navigationItem.standardAppearance = barAppearance
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    func setupCollectionView() {
        self.collectionView.backgroundColor = .collectionViewBackgroundColor
        self.collectionView.delaysContentTouches = false
        self.collectionView.isScrollEnabled = false
        
        collectionView.register(UINib(nibName: "PresetItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PresetItemCollectionViewCell")
        collectionView.register(UINib(nibName: "SettingsFooterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingsFooterCollectionViewCell")
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    func createLayout() -> UICollectionViewLayout {
        let settingsItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(144.0 / 834.0))
        let settingsItem = NSCollectionLayoutItem(layoutSize: settingsItemSize)
        
        let settingsOptionsGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(320.0 / 834.0))
        let settingsOptionsGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingsOptionsGroupSize, subitem: settingsItem, count: 2)
        settingsOptionsGroup.interItemSpacing = .fixed(32)
        settingsOptionsGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(0), top: .fixed(97), trailing: .fixed(0), bottom: .fixed(0))
        settingsOptionsGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let versionItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(80.0 / 834.0))
        let versionItem = NSCollectionLayoutItem(layoutSize: versionItemSize)
        
        let settingPageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let settingPageGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingPageGroupSize, subitems: [settingsOptionsGroup, versionItem])
        settingPageGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: settingPageGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: UICollectionViewController
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch SettingsItem.allCases[indexPath.item] {
        case .privacyPolicy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
            cell.setup(title: "Privacy Policy")
            cell.changeTitleFont(font: .systemFont(ofSize: 28, weight: .bold))
            return cell
        case .contactDevs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
            cell.setup(title: "Contact Developers")
            cell.changeTitleFont(font: .systemFont(ofSize: 28, weight: .bold))
            return cell
        case .versionNum:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsFooterCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsFooterCollectionViewCell
            cell.setup(versionLabel: "V 0.0.0")
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        switch SettingsItem.allCases[indexPath.item] {
        case .privacyPolicy:
            let url = URL(string: "https://vocable.app/privacy.html")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        case .contactDevs:
            guard MFMailComposeViewController.canSendMail() else {
                NSLog("Mail composer failed to send mail", [])
                let alert = UIAlertController(title: "Email Error", message: "There was an error creating an email. Is your device linked to an email account?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            }
            
            guard composeVC == nil else {
                break
            }
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["vocable@willowtreeapps.com"])
            self.composeVC = composeVC
            
            self.present(composeVC, animated: true, completion: nil)
        case .versionNum:
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        SettingsItem.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        switch SettingsItem.allCases[indexPath.item] {
        case .versionNum:
            return false
        default:
            return true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        switch SettingsItem.allCases[indexPath.item] {
        case .versionNum:
            return false
        default:
            return true
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
