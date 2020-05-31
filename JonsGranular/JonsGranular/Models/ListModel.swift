//
//  ListModel.swift
//  JonsGranular
//
//  Created by Jonathan Kopp on 5/30/20.
//  Copyright © 2020 Jonathan Kopp. All rights reserved.
//
import Foundation

struct Item: Codable {
    let name: String?
    let url: String?
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
    
    func imgURL() -> String {
        // Creates an image endpoint. Note: If url is nil default to known image source.
        let urlString = "https://raw.githubusercontent.com/granulartechnical/takehome-mobile/master/\(self.url ?? "Icons/1.png")"
        return urlString
    }
}

typealias List = [Item]
