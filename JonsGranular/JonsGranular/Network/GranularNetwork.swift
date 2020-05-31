//
//  GranularNetwork.swift
//  JonsGranular
//
//  Created by Jonathan Kopp on 5/30/20.
//  Copyright © 2020 Jonathan Kopp. All rights reserved.
//

import Foundation
import UIKit

struct GranularNetwork {
    /// Fetches and saves list to Core Data
    /// - Parameter completion: completes with an optional array of items.
    static func fetchList(completion: @escaping (List?) -> Void) {
        // Fetch from Core Data
        CDManager.fetchLists { (list) in
            if list != nil {
                completion(list)
            }
            // Fetch from backend and save to Core Data
            let endpoint = "list.json"
            if let url = self.urlBuilder(path: endpoint) {
                self.decodeList(url: url) { (list, _) in
                    completion(list)
                    if list != nil {
                        CDManager.saveList(list: list!)
                    }
                }
            }
        }
    }
    
    /// Creates a url request and decodes our list model.
    /// - Parameters:
    ///   - url: url to decode list object from.
    ///   - completion: List - an array of Items.
    private static func decodeList(url: URL, completion: @escaping (_ response: List?, _ networkError: Error?) -> Void) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print("🚫Network error fetching list: ", err.localizedDescription)
                completion(nil, err)
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data!, options: []) as! NSArray
                DispatchQueue.main.async {
                    let list = try! JSONDecoder().decode(List.self, from: data!)
                    completion(list,nil)
                }
            } catch {
                print("🚫Error decoding list model!")
                completion(nil,nil)
            }
        }.resume()
    }
}

// MARK: - Helper functions
extension GranularNetwork {
    
    private static func urlBuilder(path: String)-> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/granulartechnical/takehome-mobile/master/\(path)"
        return components.url
    }
}

// MARK:
extension UIImageView {
    
    /// Downloads image or fetches from Core Data if previously downloaded
    /// - Parameter link: link to fetch from.
    func downloadAndSave(from link: String) {
        guard let url = URL(string: link) else { return }
        contentMode = .scaleAspectFill
        // Add activity indicator
        let activity = UIActivityIndicatorView(frame: self.frame)
        activity.style = .large
        activity.center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
        addSubview(activity)
        activity.startAnimating()
        // Check if image has been saved to CD
        CDManager.fetchImage(for: link) { (data) in
            if data != nil {
                self.image = UIImage(data: data!)
                activity.stopAnimating()
                activity.removeFromSuperview()
            } else {
                // Image has not been downloaded before
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() {
                        CDManager.saveImage(data: data, url: link)
                        self.image = image
                        activity.stopAnimating()
                        activity.removeFromSuperview()
                    }
                }.resume()
            }
        }
        
    }
}
