//
//  PhotoTarget.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 28/8/21.
//

import Moya
import Foundation

enum PhotoTarget: FlickrTargetType {
    case search(text: String, page: Int, elementsPerPage: Int)

    var task: Task {
        switch self {
        case .search(let text, let page, let elementsPerPage):
            return .requestParameters(
                parameters: [
                    "method":"flickr.photos.search",
                    "text": text,
                    "page": page,
                    "per_page": elementsPerPage
                ],
                encoding: URLEncoding.default
            )
        }
    }

    var method: Moya.Method {
        switch self {
        case .search:
           return .get
        }
    }

    var sampleData: Data {
        switch self {
        case .search:
           return Bundle.main.jsonData(from: "PhotoSearchStubResponse") ?? Data()
        }
    }
}
