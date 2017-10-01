//
//  SmashtagTweetTableViewController.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/30/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashtagTweetTableViewController: TweetTableViewController {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        guard let searchText = searchText else { return }
        container?.performBackgroundTask { [weak self] context in
            _ = try? SearchResult.findOrCreateSearchResult(matching: searchText, tweets: tweets, context: context)
            try? context.save()
            self?.printDataBaseStatistics()
        }
    }
    
    private func printDataBaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                let searchRequest: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
                if let resultCount = (try? context.count(for: searchRequest)) {
                    print("\(resultCount) SearchResults")
                }
                let tweetRequest: NSFetchRequest<Tweet> = Tweet.fetchRequest()
                if let resultCount = (try? context.count(for: tweetRequest)) {
                    print("\(resultCount) Tweets")
                }
                let mentionRequest: NSFetchRequest<Mention> = Mention.fetchRequest()
                if let resultCount = (try? context.count(for: mentionRequest)) {
                    print("\(resultCount) Mentions")
                }
            }
        }
    }

}
