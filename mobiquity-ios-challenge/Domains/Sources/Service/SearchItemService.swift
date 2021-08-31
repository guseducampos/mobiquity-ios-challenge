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
    private let getRecentsSearchEvent: () -> AnyPublisher<[SearchItem], Never>

    init(
        saveRecent: @escaping (SearchItem) -> AnyPublisher<Void, Error>,
        getRecentsSearch: @escaping () -> AnyPublisher<[SearchItem], Never>
    ) {
        self.saveRecentEvent = saveRecent
        self.getRecentsSearchEvent = getRecentsSearch
    }

    func save(item: SearchItem) -> AnyPublisher<Void, Error> {
        saveRecentEvent(item)
    }

    func getRecentItems() -> AnyPublisher<[SearchItem], Never> {
        getRecentsSearchEvent()
    }
}

struct SearchItemService {
    let cacheStorage: CacheStorage<[SearchItem]>

    func save(item: SearchItem) -> AnyPublisher<Void, Error> {
        getRecentItems()
            .tryMap { items -> AnyPublisher<Void, Error> in
                var items = items
                let count = items.filter { $0.name == item.name }.count

                if count == 0 {
                    items.append(item)
                    return Just(try cacheStorage.save(object: items))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
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

extension SearchItemServiceClient {
   static var live: SearchItemServiceClient {
        let service = SearchItemService(cacheStorage: CacheStorage(key: "RecentSearchItemsKey"))
        return SearchItemServiceClient(
            saveRecent: service.save,
            getRecentsSearch: service.getRecentItems
        )
    }
}
