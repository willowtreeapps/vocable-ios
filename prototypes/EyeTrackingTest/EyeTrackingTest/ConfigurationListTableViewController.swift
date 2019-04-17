//
//  ConfigurationListTableViewController.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/21/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

class ConfigurationListTableViewController: UITableViewController {

    struct ConfigurationOption {
        let title: String
        let configuration: TrackingConfiguration
        let segueID: String
    }

    var configurationOptions: [ConfigurationOption] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configurationOptions = [
            ConfigurationOption(title: "Head Tracking", configuration: .headTracking, segueID: "showDemo"),
            ConfigurationOption(title: "Eye Tracking", configuration: .eyeTracking, segueID: "showDemo"),
            ConfigurationOption(title: "Six Keyboard", configuration: .headTracking, segueID: "sixKeyboard"),
        ]
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configurationOptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)

        cell.textLabel?.text = self.configurationOptions[indexPath.row].title

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let configuration = self.configurationOptions[indexPath.row]
        self.performSegue(withIdentifier: configuration.segueID, sender: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let dest = segue.destination as? ViewController,
            let selectedIndexPath = self.tableView.indexPathForSelectedRow {

            let selectedConfiguration = self.configurationOptions[selectedIndexPath.row]
            dest.trackingConfiguration = selectedConfiguration.configuration
        }
    }

}
