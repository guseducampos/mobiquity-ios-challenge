//
//  URL+Extension.swift
//  mobiquity-ios-challengeTests
//
//  Created by Gustavo Campos on 28/8/21.
//

import Foundation

extension URL {
    func components() -> (url: String, queryParameters: [String: String]) {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        var items: [String: String] = [:]

        components?.queryItems?.forEach {
            items[$0.name] = $0.value
        }

        components?.queryItems = nil
        return (url: components?.string ?? "", queryParameters: items)
    }
}
