//
//  SettingsViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import MessageUI

final class SettingsViewController: VocableCollectionViewController, MFMailComposeViewControllerDelegate {

    private weak var composeVC: MFMailComposeViewController?

    private enum Section: Int, CaseIterable {
        case internalSettings
        case externalURL
        case version
    }

    private enum SettingsItem: Int, CaseIterable {
        case categories
        case timingSensitivity
        case resetAppSettings
        case selectionMode
        case privacyPolicy
        case contactDevs
        case pidTuner
        case versionNum
        case listeningMode

        var title: String {
            switch self {
            case .categories:
                return NSLocalizedString("settings.cell.categories.title",
                                         comment: "edit categories settings menu item")
            case .timingSensitivity:
                return NSLocalizedString("settings.cell.timing_sensitivity.title",
                                         comment: "edit cursor timing and sensititivy settings menu item")
            case .resetAppSettings:
                return NSLocalizedString("settings.cell.reset_all.title",
                                         comment: "reset all settings menu item")
            case .selectionMode:
                return NSLocalizedString("settings.cell.selection_mode.title",
                                         comment: "edit cursor selection mode settings menu item")
            case .privacyPolicy:
                return NSLocalizedString("settings.cell.privacy_policy.title",
                                         comment: "view privacy policy settings menu item")
            case .contactDevs:
                return NSLocalizedString("settings.cell.contact_developers.title",
                                         comment: "contact developers settings menu item")
            case .pidTuner:
                return NSLocalizedString("settings.cell.tune_cursor.title",
                                         comment: "tune cursor debug settings menu item")
            case .listeningMode:
                return String(localized: "settings.cell.listening_mode.title")
            case .versionNum:
                return ""
            }
        }

        var isFeatureEnabled: Bool {
            let debugFeatures: [SettingsItem] = [.pidTuner]
            if debugFeatures.contains(self) {
                return AppConfig.showDebugOptions
            }
            if self == .listeningMode {
                return AppConfig.listeningMode.isFeatureFlagEnabled
            }
            return true
        }
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, SettingsItem> =
        .init(collectionView: collectionView) {(collectionView, indexPath, item) -> UICollectionViewCell in

        switch item {
        case .categories, .timingSensitivity, .resetAppSettings, .selectionMode, .listeningMode:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: item.title, image: UIImage(systemName: "chevron.right"))
            return cell
        case .privacyPolicy, .contactDevs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: item.title, image: UIImage(systemName: "arrow.up.right"))
            return cell
        case .versionNum:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsFooterCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsFooterCollectionViewCell
            cell.setup(versionLabel: SettingsViewController.versionAndBuildNumber)
            return cell
        case .pidTuner:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            cell.setup(title: item.title, image: UIImage())
            return cell
        }
    }

    static private var versionAndBuildNumber: String {
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(versionNumber)-\(buildNumber)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
    }

    private func setupNavigationBar() {
        navigationBar.title = NSLocalizedString("settings.header.title", comment: "Settings screen header title")
        navigationBar.leftButton = {
            let button = GazeableButton()
            button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
            button.accessibilityIdentifier = "settings.dismissButton"
            button.addTarget(self, action: #selector(dismissVC), for: .primaryActionTriggered)
            return button
        }()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false

        collectionView.register(UINib(nibName: "SettingsFooterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SettingsFooterCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "SettingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier)

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let self = self else {
                return nil
            }
            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            switch section {
            case .internalSettings:
                return self.internalLinksSection(environment: environment)
            case .externalURL:
                return self.externalLinksSection(environment: environment)
            case .version:
                return self.versionLabelSection(environment: environment)
            }
        }

        updateDataSource()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SettingsItem>()
        snapshot.appendSections([.internalSettings])
        snapshot.appendItems([.categories,
                              .timingSensitivity,
                              .resetAppSettings,
                              .listeningMode,
                              .selectionMode,
                              .pidTuner].filter(\.isFeatureEnabled))
        snapshot.appendSections([.externalURL])
        snapshot.appendItems([.privacyPolicy,
                              .contactDevs].filter(\.isFeatureEnabled))
        snapshot.appendSections([.version])
        snapshot.appendItems([.versionNum])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func sectionInsets(for environment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: 0,
                                       leading: max(view.layoutMargins.left - environment.container.contentInsets.leading, 0),
                                       bottom: 0,
                                       trailing: max(view.layoutMargins.right - environment.container.contentInsets.trailing, 0))
    }

    private func internalLinksSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = defaultSection(environment: environment)
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 16
        return section
    }

    private func externalLinksSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = defaultSection(environment: environment)
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 24
        return section
    }

    private func versionLabelSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInsets(for: environment)
        if sizeClass.contains(.vCompact) {
            section.contentInsets.top = 8
        } else {
            section.contentInsets.top = 24
        }
        return section
    }

    private func defaultSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension: NSCollectionLayoutDimension
        let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)
        let columnCount: Int

        if sizeClass.contains(any: .compact) {
            itemHeightDimension = .absolute(50)
        } else {
            itemHeightDimension = .absolute(100)
        }

        if sizeClass == .hCompact_vRegular {
            columnCount = 1
        } else {
            columnCount = 2
        }

        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columnCount)
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        return section
    }

    // MARK: UICollectionViewController

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .privacyPolicy:
            presentLeavingHeadTrackableDomainAlert(withConfirmation: presentPrivacyAlert)

        case .timingSensitivity:
            let viewController = TimingSensitivityViewController()
            show(viewController, sender: nil)

        case .selectionMode:
            let viewController = SelectionModeViewController()
            show(viewController, sender: nil)

        case .categories:
            let viewController = EditCategoriesViewController()
            show(viewController, sender: nil)
        case .listeningMode:
            let viewController = ListeningModeViewController()
            show(viewController, sender: nil)
        case .contactDevs:
            presentEmailAlert()

        case .pidTuner:
            presentPidTuner()
        case .resetAppSettings:
            presentAppResetPrompt()
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .versionNum:
            return false
        case .pidTuner:
            return AppConfig.isHeadTrackingEnabled
        default:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .versionNum:
            return false
        case .pidTuner:
            return AppConfig.isHeadTrackingEnabled
        default:
            return true
        }
    }

    // MARK: Actions

    @objc private func dismissVC() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    private func presentPrivacyAlert() {
        let url = URL(string: "https://vocable.app/privacy.html")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func presentLeavingHeadTrackableDomainAlert(withConfirmation confirmationAction: @escaping () -> Void) {
        let alertString = NSLocalizedString("settings.alert.surrender_gaze_confirmation.body",
                                            comment: "body of alert presented when user is about to navigate away from the head tracking-navigable portion of the app")
        let cancelTitle = NSLocalizedString("settings.alert.surrender_gaze_confirmation.button.cancel.title",
        comment: "Button cancelling the action that would have taken them away from the head tracking-navigable portion of the app")
        let confirmationTitle = NSLocalizedString("settings.alert.surrender_gaze_confirmation.button.confirm.title",
        comment: "Button confirming that the user would like to navigate away from the head tracking-navigable portion of the app")

        let alertViewController = GazeableAlertViewController(alertTitle: alertString)

        alertViewController.addAction(GazeableAlertAction(title: cancelTitle))
        alertViewController.addAction(GazeableAlertAction(title: confirmationTitle, style: .bold, handler: confirmationAction))
        present(alertViewController, animated: true)
    }

    private func presentEmailAlert() {
        if MFMailComposeViewController.canSendMail() {
            presentLeavingHeadTrackableDomainAlert(withConfirmation: presentEmail)
        } else {
            let model = UIDevice.current.systemName
            let alertString = NSLocalizedString("settings.alert.no_email_configured.title",
                                                comment: "No email account configured error alert title")
            let formattedAlertString = String(format: alertString, model)
            let dismissalTitle = NSLocalizedString("settings.alert.no_email_configured.button.dismiss.title",
                                                   comment: "No email account configured error alert dismiss button title")
            let alertViewController = GazeableAlertViewController(alertTitle: formattedAlertString)
            alertViewController.addAction(GazeableAlertAction(title: dismissalTitle))
            present(alertViewController, animated: true)
            return
        }
    }

    private func presentEmail() {
        guard composeVC == nil else { return }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["vocable@willowtreeapps.com"])
        composeVC.setSubject("Feedback for iOS Vocable \(SettingsViewController.versionAndBuildNumber)")
        self.composeVC = composeVC

        self.present(composeVC, animated: true)
    }

    private func presentPidTuner() {
        guard let gazeWindow = view.window as? HeadGazeWindow else { return }
        for child in gazeWindow.rootViewController?.children ?? [] {
            if let child = child as? UIHeadGazeViewController {
                child.pidInterpolator.pidSmoothingInterpolator.pulse.showTunningView(minimumValue: -1.0, maximumValue: 1.0)
                gazeWindow.cursorView?.isDebugCursorHidden = false
            }
        }
    }

    // MARK: Reset App Data

    private func presentAppResetPrompt() {
        let alertString = NSLocalizedString("settings.alert.reset_app_settings_confirmation.body",
                                            comment: "body of alert presented when user attempts to reset Vocable's application settings")
        let cancelTitle = NSLocalizedString("settings.alert.reset_app_settings_confirmation.button.cancel.title",
        comment: "Button cancelling the action to reset Vocable's application settings")
        let confirmationTitle = NSLocalizedString("settings.alert.reset_app_settings_confirmation.button.confirm.title",
        comment: "Button confirming that the user would like to reset Vocable's application settings")

        let alertViewController = GazeableAlertViewController(alertTitle: alertString)

        alertViewController.addAction(GazeableAlertAction(title: cancelTitle))
        alertViewController.addAction(GazeableAlertAction(title: confirmationTitle, style: .destructive, handler: { [weak self] in

            let resetController = AppResetController()
            if resetController.performReset() {
                self?.presentResetSuccessAlert()
            } else {
                self?.presentResetFailureAlert()
            }

        }))
        present(alertViewController, animated: true)
    }

    private func presentResetSuccessAlert() {
        let alertString = NSLocalizedString("settings.alert.reset_app_settings_success.body",
                                            comment: "body of alert presented when the user successfully resets Vocable's application settings")
        let dismissTitle = NSLocalizedString("settings.alert.reset_app_settings_success.button.ok",
        comment: "Button dismissing the alert informing the user that Vocable's application settings were successfully reset")

        let alertViewController = GazeableAlertViewController(alertTitle: alertString)
        alertViewController.addAction(GazeableAlertAction(title: dismissTitle))
        present(alertViewController, animated: true)
    }

    private func presentResetFailureAlert() {
        let alertString = NSLocalizedString("settings.alert.reset_app_settings_failure.body",
                                            comment: "body of alert presented when Vocable's application settings failed to reset")
        let dismissTitle = NSLocalizedString("settings.alert.reset_app_settings_failure.button.ok",
        comment: "Button dismissing the alert informing the user that Vocable's application settings failed to reset")

        let alertViewController = GazeableAlertViewController(alertTitle: alertString)
        alertViewController.addAction(GazeableAlertAction(title: dismissTitle))
        present(alertViewController, animated: true)
    }

    // MARK: MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
