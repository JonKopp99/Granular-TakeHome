//
//  CDManager.swift
//  JonsGranular
//
//  Created by Jonathan Kopp on 5/30/20.
//  Copyright © 2020 Jonathan Kopp. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class CDManager {
    /// Fetch initialized container from AppDelegate
    private static func fetchContainer() -> NSPersistentContainer? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        return appDelegate.container
    }
}

// MARK: - List Model Core Data
extension CDManager {
    
    /// Fetches previously saved list from Core Data
    static func fetchLists(completion: @escaping (_ response: List?) -> Void) {
        guard let container = fetchContainer() else {
            return
        }
        let context = container.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        do {
            let items = try context.fetch(fetchRequest)
            let names = items.first?.value(forKey: "names") as? [String]
            let urls = items.first?.value(forKey: "urls") as? [String]
            // If data exists create our list object
            if names != nil && urls != nil && names?.count == urls?.count {
                var ctr = 0
                var list = List()
                // Iterate through and append all items to our list
                for name in names! {
                    list.append(Item(name: name, url: urls![ctr]))
                    ctr += 1
                    if ctr >= names!.count {
                        completion(list)
                    }
                }
            } else {
                print("🚫Error creating Core Data list")
                completion(nil)
            }
            
        } catch let error as NSError {
            completion(nil)
            print("🚫Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// Saves new list and also deletes previous list
    static func saveList(list: List) {
        guard let container = fetchContainer() else {
            return
        }
        self.deletePreviousLists()
        // Begin saving list
        let context = container.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "ListItem",
                                       in: context)!
        let listitem = NSManagedObject(entity: entity,
                                       insertInto: context)
        let names = list.compactMap({$0.name})
        let urls = list.compactMap({$0.url})
        listitem.setValue(names, forKeyPath: "names")
        listitem.setValue(urls, forKeyPath: "urls")
        
        do {
            try context.save()
        } catch let error as NSError {
            print("🚫Error saving list: ", error.localizedDescription)
        }
    }
    /// Delete all previous lists
    private static func deletePreviousLists() {
        guard let container = fetchContainer() else {
            return
        }
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch {
            print("Error deleting previous lists")
        }
    }
}

// MARK: - Image Core Data
extension CDManager {
    
    /// Saves image to Core Data
    /// - Parameters:
    ///   - data: data representation of image object
    ///   - url: string url of image destination
    static func saveImage(data: Data, url: String) {
        guard let container = fetchContainer() else {
            return
        }
        let context = container.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "SavedImage",
                                       in: context)!
        let savedImage = NSManagedObject(entity: entity,
                                         insertInto: context)
        savedImage.setValue(data, forKeyPath: "imgData")
        savedImage.setValue(url, forKeyPath: "url")
        do {
            try context.save()
        } catch let error as NSError {
            print("🚫Error saving image: ", error.localizedDescription)
        }
    }
    
    /// Returns a saved image from our Core Data container
    /// - Parameters:
    ///   - url: destination of image
    ///   - completion: Data representation of image object
    static func fetchImage(for url: String, completion: @escaping (_ response: Data?) -> Void) {
        guard let container = fetchContainer() else {
            return
        }
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedImage")
        let predicate = NSPredicate(format: "url == %@", url)
        fetchRequest.predicate = predicate
        do {
            let items = try context.fetch(fetchRequest)
            if let imageData = items.first?.value(forKey: "ImgData") as? Data {
                completion(imageData)
            } else {
                completion(nil)
            }
        } catch let error as NSError {
            print("🚫Could not fetch. \(error), \(error.userInfo)")
            completion(nil)
        }
    }
}
