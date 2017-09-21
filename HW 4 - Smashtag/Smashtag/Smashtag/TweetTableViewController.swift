//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 7/23/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
            RecentSearchesStore.saveRecentSearch(text: searchText)
        }
    }
    
    @IBOutlet weak var homeBarButton: UIBarButtonItem!
    @IBOutlet weak var imagesBarButton: UIBarButtonItem!
    
    private var tweets = [Array<Twitter.Tweet>]()
    private var recentSearches = [RecentSearch]()
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) - filter:safe -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest {
                        self?.tweets.insert(newTweets, at: 0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        removeHomeBarButtonIfNeeded()
    }
    
    private func removeHomeBarButtonIfNeeded() {
        guard let root = navigationController?.viewControllers[0], root == self,
            var rightItems = navigationItem.rightBarButtonItems,
            rightItems.count > 1 else { return }
        rightItems.remove(at: 1)
        navigationItem.setRightBarButtonItems(rightItems, animated: false)
    }
    
    @IBOutlet weak var searchTextField: UITextField! { didSet { searchTextField.delegate = self } }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }
    
    // MARK: - Bar Button
    
    @IBAction func popToRoot(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)
        
        // Configure the cell...
        let tweet: Tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count-section)"
    }
    
    // MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "TweetDetailsSegue":
                if let vc = segue.destination as? TweetDetailsTableViewController {
                    if let index = tableView.indexPathForSelectedRow {
                        vc.tweet = tweets[index.section][index.row]
                    }
                }
            default: break
            }
        }
    }
    
}
