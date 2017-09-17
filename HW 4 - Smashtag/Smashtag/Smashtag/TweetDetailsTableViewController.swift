//
//  TweetDetailsTableViewController.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/17/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import Twitter
import SafariServices

class TweetDetailsTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet? { didSet { setupTweetData() } }
    
    private var tweetData = [(title: String, data: TweetData, count: Int)]()
    
    private enum TweetData {
        case images ([MediaItem])
        case hashtags ([Mention])
        case userMentions ([Mention])
        case urls ([Mention])
    }
    
    private func setupTweetData() {
        if let tweet = tweet {
            tweetData = [("Images", TweetData.images(tweet.media), tweet.media.count),
                         ("Hashtags", TweetData.hashtags(tweet.hashtags), tweet.hashtags.count),
                         ("Mentions", TweetData.userMentions(tweet.userMentions), tweet.userMentions.count),
                         ("URLs", TweetData.urls(tweet.urls), tweet.urls.count)
            ]
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView() // Removes lines after cells
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tweetData = self.tweetData[indexPath.section]
        switch tweetData.data {
        case .images(let mediaItems):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet Image Cell", for: indexPath) as? TweetImageCell {
                let mediaItem = mediaItems[indexPath.row]
                cell.imageURL = mediaItem.url
                return cell
            }
        case .hashtags(let mentions), .userMentions(let mentions), .urls(let mentions):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet Text Cell", for: indexPath) as? TweetTextCell {
                let mention = mentions[indexPath.row]
                cell.tweetLabel?.text = mention.keyword
                return cell
            }
        }
        return UITableViewCell()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweetData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetData[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tweetData[section].count > 0 ? tweetData[section].title : nil
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tweetData = self.tweetData[indexPath.section]
        switch tweetData.data {
        case .images(let mediaItems):
            let aspectRatio = CGFloat(mediaItems[indexPath.row].aspectRatio)
            guard aspectRatio != 0 else { return UITableViewAutomaticDimension }
            return tableView.frame.width / aspectRatio
        default: return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tweetData[indexPath.section].data {
        case .hashtags(let mentions), .userMentions(let mentions): presentSearch(from: mentions[indexPath.row].keyword)
        case .urls(let mentions): presentSafari(from: mentions[indexPath.row].keyword)
        default: break
        }
    }
    
    private func presentSearch(from text: String) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = "Tweet Table View Controller"
        guard let tweetTableVC = mainStoryboard.instantiateViewController(withIdentifier: identifier) as? TweetTableViewController else { return }
        tweetTableVC.searchText = text
        tweetTableVC.searchTextField.text = text
        show(tweetTableVC, sender: true)
    }
    
    private func presentSafari(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let sfViewController = SFSafariViewController(url: url)
        present(sfViewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if let identifier = segue.identifier, identifier == "Tweet Image View Controller" {
            if let vc = segue.destination as? TweetImageViewController {
                switch tweetData[indexPath.section].data {
                case .images(let mediaItem):
                    vc.mediaItem = mediaItem[indexPath.row]
                default: break
                }
            }
        }
    }
}

class TweetImageCell: UITableViewCell {
    
    @IBOutlet weak private var tweetImageView: UIImageView?
    
    var imageURL: URL? { didSet { updateUI() } }
    
    private var lastImageURL: URL?
    
    private func updateUI() {
        if let url = imageURL {
            lastImageURL = url
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let _self = self, let data = data, error == nil else { self?.tweetImageView?.image = nil; return }
                DispatchQueue.main.async {
                    guard url == _self.lastImageURL else { return }
                    _self.tweetImageView?.image = UIImage(data: data)
                }
            }.resume()
        } else {
            tweetImageView?.image = nil
        }
    }
    
}

class TweetTextCell: UITableViewCell {
    
    @IBOutlet weak var tweetLabel: UILabel?
    
    var tweetText: String? { didSet { updateUI() } }
    
    private func updateUI() {
        tweetLabel?.text = tweetText
    }
    
}
