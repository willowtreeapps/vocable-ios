//
//  TrackingDebugOverlayViewController.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 3/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

extension NumberFormatter {
    static let debugFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

final class TrackingDebugOverlayViewController: UIViewController, UITableViewDelegate {

    @IBOutlet private weak var tableView: UITableView!

    weak static var current: TrackingDebugOverlayViewController?

    private var dataSource: UITableViewDiffableDataSource<Int, String>?

    private var content = [String: String]() {
        didSet {
            updateSnapshot()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = .init(tableView: self.tableView) { [weak self] (tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item
            cell.detailTextLabel?.text = self?.content[item]
            return cell
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TrackingDebugOverlayViewController.current = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TrackingDebugOverlayViewController.current = nil
    }

    func setValue(_ newValue: String, forKey key: String) {
        content[key] = newValue
    }

    func setValues(_ newValues: [String: String]) {
        content.merge(newValues, uniquingKeysWith: { (_, newValue) in newValue })
    }

    private func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, item: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = item
        cell.detailTextLabel?.text = content[item]
        return cell
    }

    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(self.content.keys.sorted())
        dataSource?.apply(snapshot, animatingDifferences: false, completion: nil)
    }
}
