//
//  TweetDetailsTableViewController.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/17/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import Twitter

class TweetDetailsTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet? { didSet { setupTweetData() } }
    
    private var tweetData = [(title: String, data: TweetData, count: Int)]()
    
    private let defaultCellHeight: CGFloat = 44.0
    
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
            }
        case .hashtags(let mentions), .userMentions(let mentions), .urls(let mentions):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet Text Cell", for: indexPath) as? TweetTextCell {
                let mention = mentions[indexPath.row]
                cell.tweetLabel?.text = mention.keyword
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
            guard aspectRatio != 0 else { return defaultCellHeight }
            return tableView.frame.width / aspectRatio
        case .hashtags, .userMentions, .urls: return defaultCellHeight
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class TweetImageCell: UITableViewCell {
    
    @IBOutlet weak private var tweetImageView: UIImageView?
    
    var imageURL: URL? { didSet { updateUI() } }
    
    private var lastImageURL: URL?
    
    private func updateUI() {
        if let url = imageURL {
            lastImageURL = url
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let _self = self, let data = data, error == nil {
                    DispatchQueue.main.async {
                        if url == _self.lastImageURL {
                            _self.tweetImageView?.image = UIImage(data: data)
                        }
                    }
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
