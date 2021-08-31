//
//  SearchItemServiceTest.swift
//  mobiquity-ios-challengeTests
//
//  Created by Gustavo Campos on 29/8/21.
//

import Combine
import CombineExpectations
@testable import mobiquity_ios_challenge
import XCTest

class SearchItemServiceTest: XCTestCase {
    let cacheStorage: CacheStorage<[SearchItem]> = .init(key: "SearchItemTest")

    override func tearDown() {
        try? cacheStorage.clear()
    }

    func testSaveRecentSearchItems() throws {
        // Given
        let service = SearchItemService(cacheStorage: cacheStorage)
        let item = SearchItem(name: "test")

        // When
        let recorded = service
            .save(item: item)
            .flatMap {
                service.getRecentItems()
            }
            .record()

        let items = try wait(for: recorded.next(), timeout: 0.3)

        // Then
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "test")
    }

    func testSaveRepeatedRecentSearchItems() throws {
        // Given
        let service = SearchItemService(cacheStorage: cacheStorage)
        let item = SearchItem(name: "test")

        // Saving Items In Cache
       try cacheStorage.save(object: [item])

        // When - Saving same item again
        let recorded = service
            .save(item: item)
            .flatMap {
                service.getRecentItems()
            }
            .record()

        let items = try wait(for: recorded.next(), timeout: 0.3)

        // Then
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "test")
    }

    func testSaveRecentSearchItemsThereAreItemsInCache() throws {
        // Given
        let service = SearchItemService(cacheStorage: cacheStorage)
        let items = [
            SearchItem(name: "test1"),
            SearchItem(name: "test2"),
            SearchItem(name: "test3")
        ]

        let newItem = SearchItem(name: "test4")

        // Saving Items In Cache
       try cacheStorage.save(object: items)

        // When
        let recorded = service
            .save(item: newItem)
            .flatMap {
                service.getRecentItems()
            }
            .record()

        let newItems = try wait(for: recorded.next(), timeout: 0.3)

        // Then
        XCTAssertEqual(newItems.count, 4)
        XCTAssertEqual(newItems.last?.name, "test4")
    }
}
