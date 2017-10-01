//
//  Tweet.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/30/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class Tweet: NSManagedObject {
    
    class func findOrCreateTweetResult(matching tweet: Twitter.Tweet, searchText: String, context: NSManagedObjectContext) throws -> Tweet {
        let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", tweet.identifier, searchText)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Tweet should be unique")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let newTweet = Tweet(context: context)
        newTweet.identifier = tweet.identifier
        
        var mentions = [Twitter.Mention]()
        for hashtag in tweet.hashtags {
            mentions.append(hashtag)
        }
        for userMentions in tweet.userMentions {
            mentions.append(userMentions)
        }
        
        newTweet.mentions = NSSet(array: Mention.findOrCreateMentions(from: mentions, and: [tweet], searchText: searchText, in: context))
        return newTweet
    }
    
    class func findOrCreateTweets(from tweets: [Twitter.Tweet], searchText: String, in context: NSManagedObjectContext) -> [Tweet] {
        var newTweets = [Tweet]()
        for tweet in tweets {
            guard let tweet = try? Tweet.findOrCreateTweetResult(matching: tweet, searchText: searchText, context: context) else { continue }
            newTweets.append(tweet)
        }
        return newTweets
    }

}
