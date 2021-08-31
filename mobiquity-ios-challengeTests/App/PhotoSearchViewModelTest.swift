//
//  PhotoSearchViewModelTest.swift
//  mobiquity-ios-challengeTests
//
//  Created by Gustavo Campos on 29/8/21.
//
import Combine
import CombineExpectations
@testable import mobiquity_ios_challenge
import XCTest

class PhotoSearchViewModelTest: XCTestCase {
    typealias State = PhotoSearchViewModel.PaginationState

    func testWhenStateHasElementsAndCanContinueFetching() {
        // Given
        let state = State(
            loadingState: .idle,
            currentPage: 1,
            pages: 50,
            isNewSearch: false
        )

        // When
        let continueFetching = state.continueFetching
        let isLoading = state.isLoading

        // Then
        XCTAssertTrue(continueFetching)
        XCTAssertFalse(isLoading)
    }

    func testWhenStateCanNotContinueFetchingBecauseIsLoading() {
        // Given
        let state = State(
            loadingState: .loading,
            currentPage: 1,
            pages: 50,
            isNewSearch: false
        )

        // When
        let continueFetching = state.continueFetching
        let isLoading = state.isLoading

        // Then
        XCTAssertTrue(continueFetching)
        XCTAssertTrue(isLoading)
    }

    func testWhenStateReachMaxNumberOfPages() {
        // Given
        let state = State(
            loadingState: .idle,
            currentPage: 50,
            pages: 50,
            isNewSearch: false
        )

        // When
        let continueFetching = state.continueFetching
        let isLoading = state.isLoading

        // Then
        XCTAssertFalse(continueFetching)
        XCTAssertFalse(isLoading)
    }

    func testWhenSearchStartsAndPhotosAreReturned() throws {
        // Given
        let photo =  Photo(
            id: "12345",
            owner: "2425",
            secret: "qwrw",
            server: "wrwrw",
            farm: 44,
            title: "Test",
            isPublic: 35,
            isFriend: 22,
            isFamily: 64
        )

        
        let apiResponse = PhotoSearchResponse(
            photos: .init(
                page: 1,
                pages: 100,
                perPage: 20,
                total: 1000,
                photo: [
                    photo
               ]
            )
        )
        let photoSearchService = PhotoSearchServiceClient { _, _, _ in
            Just(
                apiResponse
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        let recentSearchItemsService =  SearchItemServiceClient { _ in
            Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } getRecentsSearch: {
            fatalError("It shouldn't reach this path")
        }

        let viewModel = PhotoSearchViewModel(
            photoSearchService: photoSearchService,
            recentSearchItemsService: recentSearchItemsService
        )

        let searchSubject = PassthroughSubject<String, Never>()

        // When
        let output = viewModel.transform(
            input: .init(
                searchImage: searchSubject.eraseToAnyPublisher(),
                nextPage: Empty().eraseToAnyPublisher()
            )
        )

        let recordedStates = output.paginationState.record()
        let recordedPhotos = output.photos.record()

        searchSubject.send("Kittens")

        let states = try wait(for: recordedStates.availableElements, timeout: 0.3)
        let photos = try wait(for: recordedPhotos.availableElements, timeout: 0.3)

        // Then
        XCTAssertEqual(states.count, 3)
        XCTAssertEqual(states, [
            State(
                loadingState: .idle,
                currentPage: 0,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .loading,
                currentPage: 1,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .idle,
                currentPage: 1,
                pages: 100,
                isNewSearch: true
            ),
        ])
        XCTAssertEqual(photos.count, 1)
    }

    func testWhenSearchIsLoading() throws {
        // Given
        let photoSearchService = PhotoSearchServiceClient { _, _, _ in
            fatalError("It shouldn't reach this path")
        }

        let recentSearchItemsService =  SearchItemServiceClient { _ in
            fatalError("It shouldn't reach this path")
        } getRecentsSearch: {
            fatalError("It shouldn't reach this path")
        }

        let viewModel = PhotoSearchViewModel(
            photoSearchService: photoSearchService,
            recentSearchItemsService: recentSearchItemsService
        )

        let searchSubject = PassthroughSubject<String, Never>()

        // When
        let output = viewModel.transform(
            input: .init(
                searchImage: searchSubject.eraseToAnyPublisher(),
                nextPage: Empty().eraseToAnyPublisher()
            ),
            initialState: .init(loadingState: .loading)
        )

        let recordedStates = output.paginationState.record()
        let recordedPhotos = output.photos.record()

        searchSubject.send("")

        let states = try wait(for: recordedStates.availableElements, timeout: 0.3)
        let photos = try wait(for: recordedPhotos.availableElements, timeout: 0.3)

        // Then
        XCTAssertEqual(states.count, 1)
        XCTAssertEqual(states, [
            State(
                loadingState: .loading,
                currentPage: 0,
                pages: nil,
                isNewSearch: true
            ),
        ])
        XCTAssertEqual(photos.count, 0)
    }

    func testWhenSearchPaginates() throws {
        // Given
        let photo =  Photo(
            id: "12345",
            owner: "2425",
            secret: "qwrw",
            server: "wrwrw",
            farm: 44,
            title: "Test",
            isPublic: 35,
            isFriend: 22,
            isFamily: 64
        )

        let apiResponse = PhotoSearchResponse(
            photos: .init(
                page: 1,
                pages: 100,
                perPage: 20,
                total: 1000,
                photo: [
                    photo
               ]
            )
        )
        let photoSearchService = PhotoSearchServiceClient { _, _, _ in
            Just(
                apiResponse
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        let recentSearchItemsService =  SearchItemServiceClient { _ in
            Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } getRecentsSearch: {
            fatalError("It shouldn't reach this path")
        }

        let viewModel = PhotoSearchViewModel(
            photoSearchService: photoSearchService,
            recentSearchItemsService: recentSearchItemsService
        )

        let searchSubject = PassthroughSubject<String, Never>()
        let paginationSubject = PassthroughSubject<Void, Never>()

        // When
        let output = viewModel.transform(
            input: .init(
                searchImage: searchSubject.eraseToAnyPublisher(),
                nextPage: paginationSubject.eraseToAnyPublisher()
            )
        )

        let recordedStates = output.paginationState.record()
        let recordedPhotos = output.photos.record()

        searchSubject.send("Kittens")

        paginationSubject.send()

        let states = try wait(for: recordedStates.availableElements, timeout: 0.3)
        let photos = try wait(for: recordedPhotos.availableElements, timeout: 0.3)
            .map(\.viewModel)
            .flatMap { $0 }

        // Then
        XCTAssertEqual(states.count, 5)
        XCTAssertEqual(states, [
            State(
                loadingState: .idle,
                currentPage: 0,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .loading,
                currentPage: 1,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .idle,
                currentPage: 1,
                pages: 100,
                isNewSearch: true
            ),
            State(
                loadingState: .loading,
                currentPage: 2,
                pages: 100,
                isNewSearch: false
            ),
            State(
                loadingState: .idle,
                currentPage: 1,
                pages: 100,
                isNewSearch: false
            )
        ])
        XCTAssertEqual(photos.map(\.photo), [photo, photo])
    }

    func testWhenSearchPaginatesIsLoadingAndRequestForANewPage() throws {
        // Given
        let photo =  Photo(
            id: "12345",
            owner: "2425",
            secret: "qwrw",
            server: "wrwrw",
            farm: 44,
            title: "Test",
            isPublic: 35,
            isFriend: 22,
            isFamily: 64
        )

        let apiResponse = PhotoSearchResponse(
            photos: .init(
                page: 1,
                pages: 100,
                perPage: 20,
                total: 1000,
                photo: [
                    photo
               ]
            )
        )

        var hangPhotoSearchRequest = false

        let photoSearchService = PhotoSearchServiceClient { _, _, _ in
            if hangPhotoSearchRequest {
               return Empty().eraseToAnyPublisher()
            } else {
                return  Just(
                    apiResponse
                )
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            }
        }

        let recentSearchItemsService =  SearchItemServiceClient { _ in
            Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } getRecentsSearch: {
            fatalError("It shouldn't reach this path")
        }

        let viewModel = PhotoSearchViewModel(
            photoSearchService: photoSearchService,
            recentSearchItemsService: recentSearchItemsService
        )

        let searchSubject = PassthroughSubject<String, Never>()
        let paginationSubject = PassthroughSubject<Void, Never>()

        // When
        let output = viewModel.transform(
            input: .init(
                searchImage: searchSubject.eraseToAnyPublisher(),
                nextPage: paginationSubject.eraseToAnyPublisher()
            )
        )

        let recordedStates = output.paginationState.record()
        let recordedPhotos = output.photos.record()

        searchSubject.send("Kittens")

        hangPhotoSearchRequest = true
        paginationSubject.send()
        paginationSubject.send()
        paginationSubject.send()

        let states = try wait(for: recordedStates.availableElements, timeout: 0.3)
        let photos = try wait(for: recordedPhotos.availableElements, timeout: 0.3)
            .map(\.viewModel)
            .flatMap { $0 }

        // Then
        XCTAssertEqual(states.count, 4)
        XCTAssertEqual(states, [
            State(
                loadingState: .idle,
                currentPage: 0,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .loading,
                currentPage: 1,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .idle,
                currentPage: 1,
                pages: 100,
                isNewSearch: true
            ),
            State(
                loadingState: .loading,
                currentPage: 2,
                pages: 100,
                isNewSearch: false
            )
        ])

        XCTAssertEqual(photos.map(\.photo), [photo])
    }

    func testWhenSearchIsPerformedOneTimeAndThenTextChanges() throws {
        // Given
        let photo =  Photo(
            id: "12345",
            owner: "2425",
            secret: "qwrw",
            server: "wrwrw",
            farm: 44,
            title: "Test",
            isPublic: 35,
            isFriend: 22,
            isFamily: 64
        )

        var page = 0
        var sendMoreItems = false

        let photoSearchService = PhotoSearchServiceClient { _, _, _ in
            if sendMoreItems {
                return Just(
                   PhotoSearchResponse(
                        photos: .init(
                            page: 1,
                            pages: 200,
                            perPage: 200,
                            total: 1000,
                            photo: [
                                photo,
                                photo
                           ]
                        )
                    )
                )
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            } else {
                page += 1
                return Just(
                    PhotoSearchResponse(
                         photos: .init(
                             page: page,
                             pages: 100,
                             perPage: 20,
                             total: 1000,
                             photo: [
                                 photo
                            ]
                         )
                     )
                 )
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            }
        }

        let recentSearchItemsService =  SearchItemServiceClient { _ in
            Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } getRecentsSearch: {
            fatalError("It shouldn't reach this path")
        }

        let viewModel = PhotoSearchViewModel(
            photoSearchService: photoSearchService,
            recentSearchItemsService: recentSearchItemsService
        )

        let searchSubject = PassthroughSubject<String, Never>()
        let paginationSubject = PassthroughSubject<Void, Never>()

        // When
        let output = viewModel.transform(
            input: .init(
                searchImage: searchSubject.eraseToAnyPublisher(),
                nextPage: paginationSubject.eraseToAnyPublisher()
            )
        )

        let recordedStates = output.paginationState.record()
        let recordedPhotos = output.photos.record()

        searchSubject.send("Kittens")
        paginationSubject.send()
        paginationSubject.send()

        sendMoreItems = true

        searchSubject.send("Dogs")

        let states = try wait(for: recordedStates.availableElements, timeout: 0.3)
        let photos = try wait(for: recordedPhotos.availableElements, timeout: 0.3)

        // Then
        XCTAssertEqual(states.count, 9)
        XCTAssertEqual(states, [
            State(
                loadingState: .idle,
                currentPage: 0,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .loading,
                currentPage: 1,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .idle,
                currentPage: 1,
                pages: 100,
                isNewSearch: true
            ),
            State(
                loadingState: .loading,
                currentPage: 2,
                pages: 100,
                isNewSearch: false
            ),
            State(
                loadingState: .idle,
                currentPage: 2,
                pages: 100,
                isNewSearch: false
            ),
            State(
                loadingState: .loading,
                currentPage: 3,
                pages: 100,
                isNewSearch: false
            ),
            State(
                loadingState: .idle,
                currentPage: 3,
                pages: 100,
                isNewSearch: false
            ),
            State(
                loadingState: .loading,
                currentPage: 1,
                pages: 100,
                isNewSearch: true
            ),
            State(
                loadingState: .idle,
                currentPage: 1,
                pages: 200,
                isNewSearch: true
            )
        ])

        let retrievedPhotos = photos.last.map(\.viewModel)
        XCTAssertEqual(retrievedPhotos?.map(\.photo), [photo, photo])
    }

    func testWhenSearchFails() throws {
        enum SearchError: Error {
            case controlledError
        }

        // Given
        let photoSearchService = PhotoSearchServiceClient { _, _, _ in
            Fail(error: SearchError.controlledError).eraseToAnyPublisher()
        }

        let recentSearchItemsService =  SearchItemServiceClient { _ in
           Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        } getRecentsSearch: {
            fatalError("It shouldn't reach this path")
        }

        let viewModel = PhotoSearchViewModel(
            photoSearchService: photoSearchService,
            recentSearchItemsService: recentSearchItemsService
        )

        let searchSubject = PassthroughSubject<String, Never>()

        // When
        let output = viewModel.transform(
            input: .init(
                searchImage: searchSubject.eraseToAnyPublisher(),
                nextPage: Empty().eraseToAnyPublisher()
            )
        )

        let recordedStates = output.paginationState.record()
        let recordedPhotos = output.photos.record()

        searchSubject.send("Kittens")

        let states = try wait(for: recordedStates.availableElements, timeout: 0.3)
        let photos = try wait(for: recordedPhotos.availableElements, timeout: 0.3)

        // Then
        XCTAssertEqual(states.count, 3)
        XCTAssertEqual(states, [
            State(
                loadingState: .idle,
                currentPage: 0,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .loading,
                currentPage: 1,
                pages: nil,
                isNewSearch: true
            ),
            State(
                loadingState: .failure,
                currentPage: 0,
                pages: nil,
                isNewSearch: true
            ),
        ])

        XCTAssertEqual(photos.count, 1)
    }
}
