//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 7/24/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    private var lastImageURL: URL?
    
    private let hashtagColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    private let urlColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    private let mentionColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
    
    private func updateUI() {
        updateTweetText()
        updateTweetUserLabel()
        updateProfileImage()
        updateTweetCreatedLabel()
    }
    
    private func updateTweetText() {
        guard let text = tweet?.text else { return }
        let mutableAttributedString = NSMutableAttributedString(string: text)
        if let hashtags = tweet?.hashtags {
            for hashtag in hashtags {
                mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: hashtagColor, range: hashtag.nsrange)
            }
        }
        if let urls = tweet?.urls {
            for url in urls {
                mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: urlColor, range: url.nsrange)
            }
        }
        if let mentions = tweet?.userMentions {
            for mention in mentions {
                mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: mentionColor, range: mention.nsrange)
            }
        }
        tweetTextLabel?.attributedText = mutableAttributedString
    }
    
    private func updateTweetUserLabel() {
        tweetUserLabel?.text = tweet?.user.description
    }
    
    private func updateProfileImage() {
        if let profileImageURL = tweet?.user.profileImageURL {
            lastImageURL = profileImageURL
            URLSession.shared.dataTask(with: profileImageURL) { [weak self] data, response, error in
                if let _self = self, let data = data, error == nil {
                    DispatchQueue.main.async {
                        if profileImageURL == _self.lastImageURL {
                            _self.tweetProfileImageView?.image = UIImage(data: data)
                        }
                    }
                }
            }.resume()
        } else {
            tweetProfileImageView?.image = nil
        }
    }
    
    private func updateTweetCreatedLabel() {
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
    
}
