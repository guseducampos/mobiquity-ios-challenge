//
//  RecentSearchService.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 29/8/21.
//

import Combine
import Foundation

struct SearchItemServiceClient {
    private let saveRecentEvent: (SearchItem) -> AnyPublisher<Void, Error>
    private let getRecentsSearchEvent: () -> AnyPublisher<[SearchItem], Error>

    init(
        saveRecent: @escaping (SearchItem) -> AnyPublisher<Void, Error>,
        getRecentsSearch: @escaping () -> AnyPublisher<[SearchItem], Error>
    ) {
        self.saveRecentEvent = saveRecent
        self.getRecentsSearchEvent = getRecentsSearch
    }

    func save(item: SearchItem) -> AnyPublisher<Void, Error> {
        saveRecentEvent(item)
    }

    func getRecentItems() -> AnyPublisher<[SearchItem], Error> {
        getRecentsSearchEvent()
    }
}

struct SearchItemService {
    let cacheStorage: CacheStorage<[SearchItem]>

    func save(item: SearchItem) -> AnyPublisher<Void, Error> {
        getRecentItems()
            .tryMap { items -> AnyPublisher<Void, Error> in
                var items = items
                items.append(item)
                return Just(try cacheStorage.save(object: items))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func getRecentItems() -> AnyPublisher<[SearchItem], Never> {
        cacheStorage
            .asyncGet()
            .catch { _ in
                Just([])
            }.eraseToAnyPublisher()
    }
}
