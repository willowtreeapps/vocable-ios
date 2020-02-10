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
    
    @IBOutlet var headerView: UINavigationItem!
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    let composeVC = MFMailComposeViewController()
    
    enum SettingsItem: CaseIterable {
        case privacyPolicy
        case contactDevs
        case versionNum
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMailComposer()
        setupNavigationBar()
        setupCollectionView()
    }
    
    func setupMailComposer() {
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["vocable@willowtreeapps.com"])
        composeVC.setSubject("Hello!")
        composeVC.setMessageBody("Hello this is my message body!", isHTML: false)
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
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
        switch SettingsItem.allCases[indexPath.item] {
        case .privacyPolicy:
            let url = URL(string: "https://vocable.app/privacy.html")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case .contactDevs:
            guard MFMailComposeViewController.canSendMail() else {
                NSLog("Mail composer failed to send mail", [])
                break
            }

            self.present(composeVC, animated: true, completion: nil)
        case .versionNum:
            break
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        SettingsItem.allCases.count
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

}
