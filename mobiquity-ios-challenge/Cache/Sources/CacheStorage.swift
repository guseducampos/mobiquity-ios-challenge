//
//  StorageCache.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 29/8/21.
//

import Combine
import Foundation

/// Saves and Retrieves Objects stored as a JSON in the app's directory
struct CacheStorage<Object: Codable> {
    private let key: String
    private let fileManager: FileManager
    private let cacheDirectoryPath: URL

    init(
        key: String,
        fileManager: FileManager = .default,
        directory: FileManager.SearchPathDirectory = .cachesDirectory,
        searchPathDomainMask: FileManager.SearchPathDomainMask = .userDomainMask
    ) {
        self.key = key
        self.fileManager = fileManager

        guard let cacheFolderDirectory = fileManager
                .urls(for: directory,
                      in: searchPathDomainMask
                ).first else {
            fatalError("Directory doesn't exist!")
        }

        self.cacheDirectoryPath = cacheFolderDirectory
    }

    /// Save the object in the specific path
    func save(
        object: Object,
        using encoder: JSONEncoder = JSONEncoder()
    ) throws {
        let data = try encoder.encode(object)
        let urlFile = cacheDirectoryPath.appendingPathComponent(key)
        try data.write(to: urlFile)
    }

    /// Get the object saved at the specific directory
    func get(
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> Object {
        let urlFile = cacheDirectoryPath.appendingPathComponent(key)
        let data = try Data(contentsOf: urlFile)
        return try decoder.decode(Object.self, from: data)
    }

    func clear() throws {
        let urlFile = cacheDirectoryPath.appendingPathComponent(key)
        try fileManager.removeItem(at: urlFile)
    }

    func asyncSave(
        object: Object,
        using encoder: JSONEncoder = JSONEncoder()
    ) -> AnyPublisher<Void, Error> {
        Future { promise in
            promise(
                Result {
                    try save(object: object, using: encoder)
                }
            )
        }
        .eraseToAnyPublisher()
    }

    func asyncGet(using decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Object, Error> {
        Future { promise in
            promise(
                Result {
                    try get(using: decoder)
                }
            )
        }
        .eraseToAnyPublisher()
    }
}
