//
//  SearchResult.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/30/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SearchResult: NSManagedObject {
    
    class func findOrCreateSearchResult(matching text: String, tweets: [Twitter.Tweet], context: NSManagedObjectContext) throws -> SearchResult {
        let request: NSFetchRequest<SearchResult> = SearchResult.fetchRequest()
        request.predicate = NSPredicate(format: "text = %@", text)
        
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "SearchResult should be unique")
                let match = matches[0]
                match.tweets = NSSet(array: Tweet.findOrCreateTweets(from: tweets, searchText: text, in: context))
                return match
            }
        } catch {
            throw error
        }
        
        let searchResult = SearchResult(context: context)
        searchResult.text = text
        searchResult.tweets = NSSet(array: Tweet.findOrCreateTweets(from: tweets, searchText: text, in: context))
        return searchResult
    }

}

