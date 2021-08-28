//
//  FlickrTargetType.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 28/8/21.
//

import Moya
import Foundation

protocol FlickrTargetType: TargetType { }

extension FlickrTargetType {
    var path: String {
        /// Not setting a path since Flickr API
        /// Identify its source through a query parameter
        return ""
    }

    var baseURL: URL {
        URL(string: "https://api.flickr.com/services/rest")!
    }

    var headers: [String : String]? {
        [:]
    }
}
