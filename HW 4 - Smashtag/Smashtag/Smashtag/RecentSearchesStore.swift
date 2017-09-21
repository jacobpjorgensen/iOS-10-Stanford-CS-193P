//
//  RecentSearchesUserDefaults.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 9/18/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import Foundation

class RecentSearchesStore {
    
    static let recentSearchesKey = "Recent Searches"
    
    static let maxSearches = 100
    
    static func saveRecentSearch(text: String?) {
        guard let text = text, text != "" else { return }
        let recentSearch = RecentSearch(date: Date(), searchText: text)
        var recentSearches = RecentSearchesStore.loadRecentSearches(sorted: false)
        
        if let index = (recentSearches.index { $0 == recentSearch }) {
            // Replace if there is a case-insensitive match
            recentSearches[index] = recentSearch
        } else if recentSearches.count == maxSearches {
            // Sort by oldest first
            var sortedSearches = recentSearches.sorted { $0 < $1 }
            // Replace the oldest search
            sortedSearches[0] = recentSearch
            RecentSearchesStore.save(recentSearches: sortedSearches)
            return
        } else {
            // Append at the end
            recentSearches.append(recentSearch)
        }
        
        RecentSearchesStore.save(recentSearches: recentSearches)
    }
    
    static func save(recentSearches: [RecentSearch]) {
        let archiveArray = NSMutableArray()
        for recentSearch in recentSearches {
            let encodedObject = NSKeyedArchiver.archivedData(withRootObject: recentSearch)
            archiveArray.add(encodedObject)
        }
        UserDefaults.standard.set(archiveArray, forKey: recentSearchesKey)
        UserDefaults.standard.synchronize()
    }
    
    static func loadRecentSearches(sorted: Bool) -> [RecentSearch] {
        guard let encodedSearches = UserDefaults.standard.array(forKey: recentSearchesKey) as? [Data]
            else { return [] }

        var recentSearches = [RecentSearch]()
        for data in encodedSearches {
            guard let recentSearch = NSKeyedUnarchiver.unarchiveObject(with: data) as? RecentSearch else { continue }
            recentSearches.append(recentSearch)
        }
        // if sorted, return newest first
        return sorted ? recentSearches.sorted { $0 > $1 } : recentSearches
    }
    
    static func sort(_ recentSearches: [RecentSearch]) -> [RecentSearch] {
        return recentSearches
    }
    
}

class RecentSearch: NSObject, NSCoding, Comparable {
    
    let date: Date?
    let searchText: String?
    
    static let dateKey = "Date"
    static let searchTextKey = "Search Text"
    
    init(date: Date, searchText: String) {
        self.date = date
        self.searchText = searchText
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        guard let date = decoder.decodeObject(forKey: RecentSearch.dateKey) as? Date,
            let searchText = decoder.decodeObject(forKey: RecentSearch.searchTextKey) as? String else { return nil }
        self.init( date: date, searchText: searchText)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.date, forKey: RecentSearch.dateKey)
        aCoder.encode(self.searchText, forKey: RecentSearch.searchTextKey)
    }
    
    // MARK: Comparable
    
    // Sorted by date
    static func < (lhs: RecentSearch, rhs: RecentSearch) -> Bool {
        guard let lhsDate = lhs.date, let rhsDate = rhs.date else { return false }
        return lhsDate < rhsDate
    }
    
    // Uniqued by text case-insensitively
    static func == (lhs: RecentSearch, rhs: RecentSearch) -> Bool {
        if let lhsText = lhs.searchText, let rhsText = rhs.searchText {
            // If both texts are non-nil, compare them case insensitively
            let compare = lhsText.caseInsensitiveCompare(rhsText)
            return compare == .orderedSame
        }
        return lhs.searchText == rhs.searchText
    }
    
}
