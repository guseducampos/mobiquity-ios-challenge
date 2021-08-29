//
//  Bundle+Extension.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 29/8/21.
//

#if DEBUG
import Foundation

extension Bundle {
    /// Use to retrieve a json file from the current bundle and transform as Data
    /// This function it's only mean to use for Moya's targets sample Data.
    func jsonData(from file: String) -> Data? {
        guard let url = self.url(
            forResource: file,
            withExtension: "json"
        ) else {
            return nil
        }

        return try? Data(contentsOf: url)
    }
}
#endif
