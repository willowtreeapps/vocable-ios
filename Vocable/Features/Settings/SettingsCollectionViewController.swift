//
//  SettingsViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import MessageUI

class SettingsCollectionViewController: UICollectionViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet private var headerView: UINavigationItem!

    private weak var composeVC: MFMailComposeViewController?
    
    private enum SettingsItem: Hashable {
        case editMySayings(String)
        case categories(String)
        case timingSensitivity(String)
        case resetAppSettings(String)
        case selectionMode(String)
        case headTrackingToggle
        case privacyPolicy(String)
        case contactDevs(String)
        case pidTuner
        case versionNum
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, SettingsItem> = .init(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
        return self.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }
    
    private var versionAndBuildNumber: String {
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(versionNumber)-\(buildNumber)"
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
        barAppearance.titleTextAttributes = textAttr
        navigationItem.standardAppearance = barAppearance
        navigationItem.largeTitleDisplayMode = .always
        
        let dismissBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark.circle")!, style: .plain, target: self, action: #selector(dismissVC))
        dismissBarButton.tintColor = .defaultTextColor
        
        navigationItem.rightBarButtonItem = dismissBarButton
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        
        collectionView.register(UINib(nibName: "PresetItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PresetItemCollectionViewCell")
        collectionView.register(UINib(nibName: "SettingsFooterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingsFooterCollectionViewCell")
        collectionView.register(UINib(nibName: "SettingsToggleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingsToggleCollectionViewCell")
        collectionView.register(UINib(nibName: "SettingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingsCollectionViewCell")

        updateDataSource()

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SettingsItem>()
        snapshot.appendSections([0])
        let titles = SettingsCellTitles.self
        if AppConfig.showPIDTunerDebugMenu {
            snapshot.appendItems([.editMySayings(titles.editSayings.rawValue),
                                  .categories(titles.categories.rawValue),
                                  .timingSensitivity(titles.timingSensitivity.rawValue),
                                  .resetAppSettings(titles.resetAppSettings.rawValue),
                                  .selectionMode(titles.selectionMode.rawValue),
                                  .pidTuner,
                                  .privacyPolicy(titles.privacyPolicy.rawValue),
                                  .contactDevs(titles.contactDevs.rawValue)])
            
        } else {
            snapshot.appendItems([.headTrackingToggle,
                                  .editMySayings(titles.editSayings.rawValue),
                                  .categories(titles.categories.rawValue),
                                  .timingSensitivity(titles.timingSensitivity.rawValue),
                                  .resetAppSettings(titles.resetAppSettings.rawValue),
                                  .selectionMode(titles.selectionMode.rawValue),
                                  .privacyPolicy(titles.privacyPolicy.rawValue),
                                  .contactDevs(titles.contactDevs.rawValue)])
        }
        snapshot.appendItems([.versionNum])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }

    func createLayout() -> UICollectionViewLayout {
        if case .compact = self.traitCollection.horizontalSizeClass, case .regular = self.traitCollection.verticalSizeClass {
            return compactWidthLayout()
        } else {
            return regularHeightWidthLayout()
        }
    }
    
    private func compactWidthLayout() -> UICollectionViewLayout {
        let internalLinksItemCount = dataSource.snapshot().itemIdentifiers.count - 3
//        let headTrackingToggleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        let settingsButtonItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        let internalLinksGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(4 / 6))
        let internalLinksGroup = NSCollectionLayoutGroup.vertical(layoutSize: internalLinksGroupSize, subitem: settingsButtonItem, count: internalLinksItemCount)
        internalLinksGroup.interItemSpacing = .fixed(8)
        
        let externalLinksGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1 / 4))
        let externalLinksGroup = NSCollectionLayoutGroup.vertical(layoutSize: externalLinksGroupSize, subitem: settingsButtonItem, count: 2)
        externalLinksGroup.interItemSpacing = .fixed(8)
        externalLinksGroup.edgeSpacing = .init(leading: nil, top: .fixed(24), trailing: nil, bottom: nil)
        
        let versionItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/7))
        let versionItem = NSCollectionLayoutItem(layoutSize: versionItemSize)
        
        let settingPageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.8))
        let settingPageGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingPageGroupSize, subitems: [internalLinksGroup, externalLinksGroup, versionItem])
        
        let section = NSCollectionLayoutSection(group: settingPageGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func regularHeightWidthLayout() -> UICollectionViewLayout {
        let itemCount = dataSource.snapshot().itemIdentifiers.count - 2

        let settingsButtonItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 2), heightDimension: .fractionalHeight(1.0)))
        
        let internalLinkRowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                              heightDimension: .fractionalHeight(1.0))
        let internalLinkRowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: internalLinkRowGroupSize,
                                                                      subitem: settingsButtonItem,
                                                                      count: 2)
        internalLinkRowGroup.interItemSpacing = .fixed(8.0)
        
        let internalLinkContainerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                    heightDimension: .fractionalHeight(0.6))
        let internalLinkContainerGroup = NSCollectionLayoutGroup.vertical(layoutSize: internalLinkContainerGroupSize,
                                                                          subitem: internalLinkRowGroup,
                                                                          count: 3)
        
        let externalLinkContainerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.2))
        
        internalLinkContainerGroup.edgeSpacing = .init(leading: nil, top: nil, trailing: nil, bottom: .fixed(24))
        internalLinkContainerGroup.interItemSpacing = .fixed(8.0)
        
        let externalLinkContainerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: externalLinkContainerGroupSize, subitem: settingsButtonItem, count: 2)
        externalLinkContainerGroup.interItemSpacing = .fixed(8.0)
        
        let versionItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(80.0 / 834.0))
        let versionItem = NSCollectionLayoutItem(layoutSize: versionItemSize)
        
        let settingPageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let settingPageGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingPageGroupSize, subitems: [internalLinkContainerGroup, externalLinkContainerGroup, versionItem])
        
        let section = NSCollectionLayoutSection(group: settingPageGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: UICollectionViewController
    
    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: SettingsItem) -> UICollectionViewCell {
        switch item {
        case .headTrackingToggle:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsToggleCollectionViewCell
            cell.setup(title: NSLocalizedString("Head Tracking", comment: "Head tracking cell title"))
            return cell
        case .editMySayings(let title), .categories(let title), .timingSensitivity(let title), .resetAppSettings(let title), .selectionMode(let title):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: title, image: UIImage(systemName: "chevron.right"))
            return cell
        case .privacyPolicy(let title), .contactDevs(let title):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: title, image: UIImage(systemName: "arrow.up.right"))
            return cell
        case .versionNum:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsFooterCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsFooterCollectionViewCell
            cell.setup(versionLabel: versionAndBuildNumber)
            return cell
        case .pidTuner:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: "Tune Cursor", image: UIImage())
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
        case .headTrackingToggle:
            if AppConfig.isHeadTrackingEnabled {
                let alertViewController = GazeableAlertViewController.make { AppConfig.isHeadTrackingEnabled.toggle() }
                present(alertViewController, animated: true)
                alertViewController.setAlertTitle("Turn off head tracking?")
            } else {
                AppConfig.isHeadTrackingEnabled.toggle()
            }

        case .privacyPolicy:
            let alertViewController = GazeableAlertViewController.make { self.presentPrivacyAlert() }
            present(alertViewController, animated: true)
            alertViewController.setAlertTitle("You're about to be taken outside of the Vocable app. You may lose head tracking control.")
        
        case .editMySayings:
            if let vc = self.storyboard?.instantiateViewController(identifier: "MySayings") {
                show(vc, sender: nil)
            }
        case .contactDevs:
            let alertViewController = GazeableAlertViewController.make { self.presentEmail() }
            present(alertViewController, animated: true)
            alertViewController.setAlertTitle("You're about to be taken outside of the Vocable app. You may lose head tracking control.")

        case .pidTuner:
            guard let gazeWindow = view.window as? HeadGazeWindow else { return }
            for child in gazeWindow.rootViewController?.children ?? [] {
                if let child = child as? UIHeadGazeViewController {
                    child.pidInterpolator.pidSmoothingInterpolator.pulse.showTunningView(minimumValue: -1.0, maximumValue: 1.0)
                    gazeWindow.cursorView.isDebugCursorHidden = false
                }
            }
        default:
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

    // MARK: Presentations

    private func presentPrivacyAlert() {
        let url = URL(string: "https://vocable.app/privacy.html")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func presentEmail() {

        guard MFMailComposeViewController.canSendMail() else {
            NSLog("Mail composer failed to send mail", [])
            return
        }

        guard composeVC == nil else {
            return
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["vocable@willowtreeapps.com"])
        composeVC.setSubject("Feedback for Vocable v\(versionAndBuildNumber)")
        self.composeVC = composeVC

        self.present(composeVC, animated: true)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
