//
//  SearchItem.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 29/8/21.
//

import Foundation

struct SearchItem: Codable, Identifiable {
    var id = UUID()
    let name: String
}
