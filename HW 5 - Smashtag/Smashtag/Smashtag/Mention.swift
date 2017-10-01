//
//  Mention.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/30/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Mention: NSManagedObject {
    
    class func findOrCreateMention(from mention: Twitter.Mention, with tweets: [Twitter.Tweet], and searchText: String, context: NSManagedObjectContext) throws -> Mention {
        let request: NSFetchRequest<Mention> = Mention.fetchRequest()
        request.predicate = NSPredicate(format: "text = %@ and searchText = %@", mention.keyword, searchText)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Mention should be unique")
                matches[0].count += 1
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let newMention = Mention(context: context)
        newMention.count = 1
        newMention.text = mention.keyword
        newMention.tweets = NSSet(array: Tweet.findOrCreateTweets(from: tweets, searchText: searchText, in: context))
        newMention.searchText = searchText
        return newMention
    }
    
    class func findOrCreateMentions(from mentions: [Twitter.Mention], and tweets: [Twitter.Tweet], searchText: String, in context: NSManagedObjectContext) -> [Mention] {
        var newMentions = [Mention]()
        for mention in mentions {
            guard let mention = try? Mention.findOrCreateMention(from: mention, with: tweets, and: searchText, context: context) else { continue }
            newMentions.append(mention)
        }
        return newMentions
    }

}
