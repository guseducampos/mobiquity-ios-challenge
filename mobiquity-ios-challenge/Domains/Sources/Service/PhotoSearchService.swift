//
//  PhotoSearchService.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 28/8/21.
//

import Combine
import Foundation

typealias PhotoSearchResponse = APIResponse<[Photo]>

struct PhotoSearchServiceClient {
    private let photoSearchRequest: (String, Int, Int) -> AnyPublisher<PhotoSearchResponse, Error>

    init(
        photoSearchRequest: @escaping (String, Int, Int) -> AnyPublisher<PhotoSearchResponse, Error>
    ) {
        self.photoSearchRequest = photoSearchRequest
    }

    func photoSearch(
        text: String,
        page: Int,
        elementsPerPage perPage: Int = 20
    ) -> AnyPublisher<PhotoSearchResponse, Error> {
        photoSearchRequest(text, page, perPage)
    }
}

struct PhotoSearchService {
    private let networkProvider: NetworkProvider

    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    func photoSearch(
        text: String,
        page: Int,
        elementsPerPage perPage: Int = 20
    ) -> AnyPublisher<PhotoSearchResponse, Error> {
        networkProvider.request(
            target: PhotoTarget.search(
                text: text,
                page: page,
                elementsPerPage: perPage
            )
        )
    }
}
