import UIKit
import MessageUI

final class SettingsViewController: VocableCollectionViewController, MFMailComposeViewControllerDelegate {

    private typealias DataSource = UICollectionViewDiffableDataSource<SettingsViewController.Section, SettingsItem>
    private typealias CellRegistration = UICollectionView.CellRegistration<VocableListCell, SettingsItem>
    
    private var dataSource: DataSource!
    private var cellRegistration: CellRegistration!
    
    private weak var composeVC: MFMailComposeViewController?

    private enum Section: Int, CaseIterable {
        case internalSettings
        case externalURL
    }

    private enum SettingsItem: Int, CaseIterable {
        case categories
        case timingSensitivity
        case resetAppSettings
        case selectionMode
        case privacyPolicy
        case contactDevs
        case pidTuner
        case listeningMode
        case voiceConfiguration
        case darkMode // P5161

        var title: String {
            switch self {
            case .categories:
                return String(localized: "settings.cell.categories.title")
            case .timingSensitivity:
                return String(localized: "settings.cell.timing_sensitivity.title")
            case .resetAppSettings:
                return String(localized: "settings.cell.reset_all.title")
            case .selectionMode:
                return String(localized: "settings.cell.selection_mode.title")
            case .privacyPolicy:
                return String(localized: "settings.cell.privacy_policy.title")
            case .contactDevs:
                return String(localized: "settings.cell.contact_developers.title")
            case .pidTuner:
                return "Tune Cursor" // Debug-only, not localized
            case .listeningMode:
                return String(localized: "settings.cell.listening_mode.title")
            case .voiceConfiguration:
                return String(localized: "settings.cell.voice_configuration.title")
            case .darkMode:
                return String(localized: "settings.cell.dark_mode.title") // Pb4e7
            }
        }
        
        var accessibiltyId: AccessibilityID {
            switch self {
            case .categories:
                return .settings.categoriesAndPhrasesCell
            case .timingSensitivity:
                return .settings.timingAndSensitivityCell
            case .resetAppSettings:
                return .settings.resetAppSettingsCell
            case .selectionMode:
                return .settings.selectionModeCell
            case .privacyPolicy:
                return .settings.privacyPolicyCell
            case .contactDevs:
                return .settings.contactDevelopersCell
            case .listeningMode:
                return .settings.listeningModeCell
            case .voiceConfiguration:
                return .settings.voiceSettingsCell
            case .pidTuner:
                return ""
            case .darkMode:
                return .settings.darkModeCell // Pb4e7
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
    
    private enum SupplementaryKind: String {
        case versionNumberFooter
    }

    private var versionAndBuildNumber: String {
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let formattedVersion = versionNumber + " (\(buildNumber))"
        let format = String(
            localized: "settings.version_format",
            defaultValue: "Version %1$@",
            comment: "Version information displayed at the bottom of the Settings screen. Argument is the application version."
        )
        return String(format: format, formattedVersion)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
    }

    private func setupNavigationBar() {
        navigationBar.title = String(localized: "settings.header.title")
        navigationBar.leftButton = {
            let button = GazeableButton()
            button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
            button.accessibilityID = .shared.dismissButton
            button.addTarget(self, action: #selector(dismissVC), for: .primaryActionTriggered)
            return button
        }()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        
        collectionView.register(UINib(nibName: "SettingsFooterTextSupplementaryView", bundle: nil),
                                forSupplementaryViewOfKind: SupplementaryKind.versionNumberFooter.rawValue,
                                withReuseIdentifier: SupplementaryKind.versionNumberFooter.rawValue)
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let self else { return nil }
            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            switch section {
            case .internalSettings:
                return self.internalLinksSection(environment: environment)
            case .externalURL:
                return self.externalLinksSection(environment: environment)
            }
        }
        
        let cellRegistration = CellRegistration { [weak self] cell, _, item in
            if [.privacyPolicy, .contactDevs].contains(item) {
                cell.contentConfiguration = VocableListContentConfiguration(
                    title: item.title,
                    trailingAccessory: .systemImage("arrow.up.right")
                ) {
                    self?.handleItemSelection(item)
                }
                cell.accessibilityID = item.accessibiltyId
            } else {
                cell.contentConfiguration = VocableListContentConfiguration.disclosureCell(title: item.title) {
                    self?.handleItemSelection(item)
                }
                cell.accessibilityID = item.accessibiltyId
            }
        }
        
        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) in
            guard let self else { return UICollectionReusableView() }
            switch SupplementaryKind(rawValue: elementKind) {
            case .none:
                return UICollectionReusableView()
            case .versionNumberFooter:
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: elementKind, for: indexPath) as! SettingsFooterTextSupplementaryView
                footer.textLabel.text = self.versionAndBuildNumber
                footer.textLabel.textAlignment = .center
                return footer
            }
        }
        
        self.cellRegistration = cellRegistration
        updateDataSource()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SettingsItem>()
        snapshot.appendSections([.internalSettings])
        snapshot.appendItems([.voiceConfiguration,
                              .categories,
                              .timingSensitivity,
                              .listeningMode,
                              .selectionMode,
                              .resetAppSettings,
                              .darkMode].filter(\.isFeatureEnabled)) // P83a5
        snapshot.appendSections([.externalURL])
        snapshot.appendItems([.privacyPolicy,
                              .contactDevs].filter(\.isFeatureEnabled))
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func sectionInsets(for environment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(
            top: 0,
            leading: max(view.layoutMargins.left - environment.container.contentInsets.leading, 0),
            bottom: 0,
            trailing: max(view.layoutMargins.right - environment.container.contentInsets.trailing, 0)
        )
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
        section.contentInsets.bottom = 16
        
        let versionItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(88)),
            elementKind: SupplementaryKind.versionNumberFooter.rawValue,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [
            versionItem
        ]
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

    private func handleItemSelection(_ item: SettingsItem) {
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
        case .voiceConfiguration:
            let viewController = VoiceSettingsViewController()
            show(viewController, sender: nil)
        case .contactDevs:
            presentEmailAlert()
        case .pidTuner:
            presentPidTuner()
        case .resetAppSettings:
            presentAppResetPrompt()
        case .darkMode:
            toggleDarkMode() // P83a5
        }
    }
    
    private func toggleDarkMode() {
        AppSettings().darkModeEnabled.toggle()
        updateAppearance()
    }

    private func updateAppearance() {
        let window = UIApplication.shared.windows.first
        window?.overrideUserInterfaceStyle = AppSettings().darkModeEnabled ? .dark : .light
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .pidTuner:
            return AppConfig.isHeadTrackingEnabled
        default:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
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
        let alertString = String(localized: "settings.alert.surrender_gaze_confirmation.body")
        let cancelTitle = String(localized: "settings.alert.surrender_gaze_confirmation.button.cancel.title")
        let confirmationTitle = String(localized: "settings.alert.surrender_gaze_confirmation.button.confirm.title")

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
            let alertString = String(localized: "settings.alert.no_email_configured.title")
            let formattedAlertString = String(format: alertString, model)
            let dismissalTitle = String(localized: "settings.alert.no_email_configured.button.dismiss.title")
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
        composeVC.setSubject("Feedback for iOS Vocable \(versionAndBuildNumber)")
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
        let alertString = String(localized: "settings.alert.reset_app_settings_confirmation.body")
        let cancelTitle = String(localized: "settings.alert.reset_app_settings_confirmation.button.cancel.title")
        let confirmationTitle = String(localized: "settings.alert.reset_app_settings_confirmation.button.confirm.title")

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
        let alertString = String(localized: "settings.alert.reset_app_settings_success.body")
        let dismissTitle = String(localized: "settings.alert.reset_app_settings_success.button.ok")

        let alertViewController = GazeableAlertViewController(alertTitle: alertString)
        alertViewController.addAction(GazeableAlertAction(title: dismissTitle))
        present(alertViewController, animated: true)
    }

    private func presentResetFailureAlert() {
        let alertString = String(localized: "settings.alert.reset_app_settings_failure.body")
        let dismissTitle = String(localized: "settings.alert.reset_app_settings_failure.button.ok")

        let alertViewController = GazeableAlertViewController(alertTitle: alertString)
        alertViewController.addAction(GazeableAlertAction(title: dismissTitle))
        present(alertViewController, animated: true)
    }

    // MARK: MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
