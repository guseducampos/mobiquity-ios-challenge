//
//  CacheStorageTest.swift
//  mobiquity-ios-challengeTests
//
//  Created by Gustavo Campos on 29/8/21.
//

@testable import mobiquity_ios_challenge
import XCTest

class CacheStorageTest: XCTestCase {
    let cacheStorage: CacheStorage<SearchItem> = .init(key: "SearchItemTest")

    override func tearDown() {
        try? cacheStorage.clear()
    }

    func testSaveAndGetItemInStorage() throws {
        // Given
        let item = SearchItem(name: "Test")

        // When
        try cacheStorage.save(object: item)
        let savedItem = try cacheStorage.get()

        // Then
        XCTAssertEqual(savedItem.name, "Test")
    }

    func testDeleteItemInStorage() throws {
        // Given
        let item = SearchItem(name: "Test")

        // When
        try cacheStorage.save(object: item)
        try cacheStorage.clear()

        // Then
        XCTAssertThrowsError(try cacheStorage.get())
    }
}
