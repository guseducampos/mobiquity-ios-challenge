//
//  APIResponse.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 28/8/21.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    struct Response: Decodable {
        let page: Int
        let pages: Int
        let perPage: Int
        let total: Int
        let photo: T

        enum CodingKeys: String, CodingKey {
            case page
            case pages
            case perPage = "perpage"
            case total
            case photo
        }
    }

    let photos: Response
}
