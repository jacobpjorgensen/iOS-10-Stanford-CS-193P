//
//  RecentSearchesTableViewController.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/18/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit

class RecentSearchesTableViewController: UITableViewController {
    
    private var recentSearches = [RecentSearch]()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recentSearches = RecentSearchesStore.loadRecentSearches(sorted: true)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Recent Tweet Search Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RecentTweetSearchCell
        cell?.searchTextLabel.text = recentSearches[indexPath.row].searchText
        if let date = recentSearches[indexPath.row].date {
            cell?.dateLabel.text = dateFormatter.string(from: date)
        }
        return cell ?? UITableViewCell()
    }
    
    // MARK: - Editing
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        recentSearches.remove(at: indexPath.row)
        tableView.endUpdates()
        RecentSearchesStore.save(recentSearches: recentSearches)
    }
    
}

class RecentTweetSearchCell: UITableViewCell {
    
    @IBOutlet weak var searchTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
}
