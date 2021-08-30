//
//  PhotoSearchViewModel.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 29/8/21.
//

import Combine
import CombineExt
import Foundation

final class PhotoSearchViewModel {
    enum LoadingState {
        case loading
        case idle
        case failure
    }

    struct PaginationState: Equatable {
        var loadingState: LoadingState = .idle
        var currentPage: Int = 0
        var pages: Int?
        var isNewSearch: Bool = true

        var continueFetching: Bool {
            pages != currentPage
        }

        var isLoading: Bool {
            loadingState == .loading
        }

        mutating func updateState(
            loadingState: LoadingState,
            currentPage: Int,
            pages: Int?
        ) {
            self.loadingState = loadingState
            self.currentPage = currentPage
            self.pages = pages
        }
    }

    struct Input {
        let searchImage: AnyPublisher<String, Never>
        let nextPage: AnyPublisher<Void, Never>
    }

    struct Output {
        var paginationState: AnyPublisher<PaginationState, Never>
        var photos: AnyPublisher<[PhotoViewModel], Never>
    }

    private let photoSearchService: PhotoSearchServiceClient
    private let recentSearchItemsService: SearchItemServiceClient

    init(
        photoSearchService: PhotoSearchServiceClient,
        recentSearchItemsService: SearchItemServiceClient
    ) {
        self.photoSearchService = photoSearchService
        self.recentSearchItemsService = recentSearchItemsService
    }

    func transform(
        input: Input,
        initialState state: PaginationState = .init()
    ) -> Output {
        // Value Subject to hold the current view state
        let stateSubject: CurrentValueSubject<PaginationState, Never> = .init(state)

        // search event validates if the text changes
        // and if there is a request on going
        let searchEvent = input
            .searchImage
            .removeDuplicates()
            .withLatestFrom(stateSubject) { text, state -> (String, PaginationState) in
                (text, state)
            }
            .eraseToAnyPublisher()
            .filter { _, state in
                !state.isLoading
            }

        // Perform all of the logic related with the pagination
        // and the accumulation of the number of pages
        let paginationEvent = searchEvent
            .flatMapLatest { (text, _) -> AnyPublisher<(String, PaginationState), Never> in
                input
                    .nextPage
                    .prepend(()) // firing the publisher
                    .withLatestFrom(stateSubject)
                    .filter { state in
                       return state.continueFetching && !state.isLoading
                    }
                    .handleEvents(receiveOutput: { currentState in
                        var currentState = currentState
                        currentState.loadingState = .loading
                        stateSubject.send(currentState)
                    })
                    .map { _ in () }
                    .scan(0) { currentPage, _ in
                        currentPage + 1
                    }
                    .withLatestFrom(stateSubject) { page, newState -> (Int, PaginationState) in
                        return (page, newState)
                    }
                    .map { (currentPage, newState) -> (String, PaginationState) in
                        var newState = newState
                        newState.currentPage = currentPage
                        newState.isNewSearch = currentPage == 1 // Check if is a new request in order to reset the photos array
                        return (text, newState)
                    }
                    .eraseToAnyPublisher()
            }

        // Perform the request to the API
        // and accumulates the result from it.
        let searchRequest = paginationEvent
            .flatMap { [photoSearchService, recentSearchItemsService] text, state -> AnyPublisher<[Photo], Never> in
                photoSearchService
                    .photoSearch(text: text, page: state.currentPage)
                    .flatMap { response -> AnyPublisher<PhotoSearchResponse, Error> in
                        /// Saving current search into the local storage
                        recentSearchItemsService.save(item: SearchItem(name: text))
                            .map { _ in
                                response
                            }.catch { _  -> AnyPublisher<PhotoSearchResponse, Error> in
                                Just(response)
                                    .setFailureType(to: Error.self)
                                    .eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
                    .result()
                    .handleEvents(receiveOutput: { result in
                        var newState = state
                        switch result {
                        case .success(let response):
                            newState.updateState(
                                loadingState: .idle,
                                currentPage: response.photos.page,
                                pages: response.photos.pages
                            )
                        case .failure:
                            newState
                                .updateState(
                                    loadingState: .failure,
                                    currentPage: state.currentPage - 1, // Request fails needs to return to the previous page value
                                    pages: state.pages
                                )
                        }
                        stateSubject.send(newState)
                    })
                    .map { result -> [Photo] in
                        switch result {
                        case .success(let response):
                            return response.photos.photo
                        case .failure:
                            return []
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .withLatestFrom(stateSubject) { photos, newState -> ([Photo], PaginationState) in
                return (photos, newState)
            }
            // Uses scan to accumulate the collected values
            .scan([Photo](), { pastPhotos, newValues in
                let (newPhotos, state) = newValues
                // If is new search return the new elements
                // Instead of accumulate them
                if state.isNewSearch {
                    return newPhotos
                } else {
                    return pastPhotos + newPhotos
                }
            })
            .eraseToAnyPublisher()

        return Output(
            paginationState: stateSubject.eraseToAnyPublisher(),
            photos: searchRequest
                .map { photos in
                    photos.compactMap(PhotoViewModel.init)
                }
                .share()
                .eraseToAnyPublisher()
        )
    }
}
