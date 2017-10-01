//
//  PopularMentionsTableViewController.swift
//  Smashtag
//
//  Created by Jacob Jorgensen on 10/1/17.
//  Copyright © 2017 Jacob Jorgensen. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class PopularMentionsTableViewController: FetchedResultsTableViewController {
    
    var searchTerm: String?
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet { updateUI() } }
    
    var fetchedResultsController: NSFetchedResultsController<Mention>?
    
    private func updateUI() {
        if let context = container?.viewContext, let searchTerm = searchTerm {
            let request : NSFetchRequest<Mention> = Mention.fetchRequest()
            let alphabeticalSort = NSSortDescriptor(key: "text", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
            request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false), alphabeticalSort]
            request.predicate = NSPredicate(format: "count > %@ and searchText contains[c] %@", 1 as NSNumber, searchTerm)
            fetchedResultsController = NSFetchedResultsController<Mention>(
                fetchRequest: request,
               managedObjectContext: context,
               sectionNameKeyPath: nil,
               cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopularMentionsCell", for: indexPath)
        
        if let mention = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = mention.text
            cell.detailTextLabel?.text = "Number of Tweets: \(Int(mention.count))"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mention = fetchedResultsController?.object(at: indexPath), let text = mention.text {
            presentSearch(from: text)
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
    
}
