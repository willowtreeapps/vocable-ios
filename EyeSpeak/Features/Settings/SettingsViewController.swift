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
    
    private enum SettingsItem: CaseIterable {
        case privacyPolicy
        case contactDevs
        case pidTuner
        case versionNum
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, SettingsItem> = .init(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
        return self.collectionView(collectionView, cellForItemAt: indexPath, item: item)
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

        updateDataSource()

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SettingsItem>()
        snapshot.appendSections([0])
        snapshot.appendItems([.privacyPolicy, .contactDevs])
        if AppConfig.showPIDTunerDebugMenu {
            snapshot.appendItems([.pidTuner])
        }
        snapshot.appendItems([.versionNum])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemCount = dataSource.snapshot().itemIdentifiers.count
        let settingsItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(144.0 / 834.0))
        let settingsItem = NSCollectionLayoutItem(layoutSize: settingsItemSize)
        
        let settingsOptionsGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight((144.0 * CGFloat(itemCount)) / 834.0))
        let settingsOptionsGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingsOptionsGroupSize, subitem: settingsItem, count: itemCount)
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
    
    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: SettingsItem) -> UICollectionViewCell {
        switch item {
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
        case .pidTuner:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
            cell.setup(title: "Tune Cursor")
            cell.changeTitleFont(font: .systemFont(ofSize: 28, weight: .bold))
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
        case .privacyPolicy:
            let url = URL(string: "https://vocable.app/privacy.html")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        case .contactDevs:
            guard MFMailComposeViewController.canSendMail() else {
                NSLog("Mail composer failed to send mail", [])
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
        case .pidTuner:
            guard let gazeWindow = view.window as? HeadGazeWindow else { return }
            for child in gazeWindow.rootViewController?.children ?? [] {
                if let child = child as? UIHeadGazeViewController {
                    child.pidInterpolator.pidSmoothingInterpolator.pulse.showTunningView(minimumValue: -1.0, maximumValue: 1.0)
                    gazeWindow.cursorView?.isDebugCursorHidden = false
                }
            }
        case .versionNum:
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
        case .versionNum:
            return false
        default:
            return true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
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
