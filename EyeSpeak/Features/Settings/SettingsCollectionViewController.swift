//
//  SettingsViewController.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import MessageUI

class SettingsCollectionViewController: UICollectionViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet private var headerView: UINavigationItem!
    
    private weak var composeVC: MFMailComposeViewController?
    
    private enum SettingsItem: CaseIterable {
        case headTrackingToggle
        case privacyPolicy
        case contactDevs
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

        updateDataSource()

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SettingsItem>()
        snapshot.appendSections([0])
        snapshot.appendItems([.headTrackingToggle, .privacyPolicy, .contactDevs])
        if AppConfig.showPIDTunerDebugMenu {
            snapshot.appendItems([.pidTuner])
        }
        snapshot.appendItems([.versionNum])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemCount = dataSource.snapshot().itemIdentifiers.count - 2
        let headTrackingToggleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let settingsButtonItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 2), heightDimension: .fractionalHeight(1 / 2)))
        
        let settingsToggleGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1 / 6))
        let settingsToggleGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingsToggleGroupSize, subitem: headTrackingToggleItem, count: 1)
        settingsToggleGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32)
        settingsToggleGroup.edgeSpacing = .init(leading: nil, top: .fixed(32), trailing: nil, bottom: .fixed(92))
        
        let settingsOptionsGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(3 / 6))
        let settingsOptionsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: settingsOptionsGroupSize, subitem: settingsButtonItem, count: itemCount)
        settingsOptionsGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32)
        settingsOptionsGroup.interItemSpacing = .fixed(16)
        
        let versionItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(80.0 / 834.0))
        let versionItem = NSCollectionLayoutItem(layoutSize: versionItemSize)
        
        let settingPageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let settingPageGroup = NSCollectionLayoutGroup.vertical(layoutSize: settingPageGroupSize, subitems: [settingsToggleGroup, settingsOptionsGroup, versionItem])
        settingPageGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: settingPageGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: UICollectionViewController
    
    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: SettingsItem) -> UICollectionViewCell {
        switch item {
        case .headTrackingToggle:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsToggleCollectionViewCell
            cell.setup(title: NSLocalizedString("Head Tracking", comment: "Head tracking cell title") )
            return cell
        case .privacyPolicy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
            cell.setup(title: NSLocalizedString("Privacy Policy", comment: "Privacy policy cell title") )
            return cell
        case .contactDevs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
            cell.setup(title: NSLocalizedString("Contact developers", comment: "Contact developers cell title") )
            return cell
        case .versionNum:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsFooterCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsFooterCollectionViewCell
            cell.setup(versionLabel: versionAndBuildNumber)
            return cell
        case .pidTuner:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
            cell.setup(title: NSLocalizedString("Tune Cursor", comment: "Tune cursor cell title") )
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
                alertViewController.setAlertTitle("Turn off head tracking? Really?")
            } else {
                AppConfig.isHeadTrackingEnabled.toggle()
            }

        case .privacyPolicy:
            let alertViewController = GazeableAlertViewController.make { self.presentPrivacyAlert() }
            present(alertViewController, animated: true)
            alertViewController.setAlertTitle("You’re about to be taken outside of the app. You may lose head tracking control.")

        case .contactDevs:
            let alertViewController = GazeableAlertViewController.make { self.presentEmail() }
            present(alertViewController, animated: true)
            alertViewController.setAlertTitle("You’re about to be taken outside of the app. You may lose head tracking control.")

        case .pidTuner:
            guard let gazeWindow = view.window as? HeadGazeWindow else { return }
            for child in gazeWindow.rootViewController?.children ?? [] {
                if let child = child as? UIHeadGazeViewController {
                    child.pidInterpolator.pidSmoothingInterpolator.pulse.showTunningView(minimumValue: -1.0, maximumValue: 1.0)
                    gazeWindow.cursorView.isDebugCursorHidden = false
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
