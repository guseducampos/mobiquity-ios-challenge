//
//  PhotoTargetTest.swift
//  mobiquity-ios-challengeTests
//
//  Created by Gustavo Campos on 28/8/21.
//

import Combine
import CombineExpectations
import Moya
@testable import mobiquity_ios_challenge
import XCTest

class PhotoTargetTest: XCTestCase {
    func testPhotoSearchRequest() throws {
        // Given
        let moyaProvider = MoyaProvider<PhotoTarget>(
            stubClosure: MoyaProvider.immediatelyStub,
            plugins: [
                FlickrPlugin(token: "12345")
            ]
        )
        let text = "kittens"

        // When
        let recordedRequest = moyaProvider.request(target: .search(text: text, page: 1, elementsPerPage: 1)).record()
        let response = try wait(for: recordedRequest.next(), timeout: 0.3)

        // Then
        let (url, queryParameters) = try XCTUnwrap(response.request?.url?.components())

        XCTAssertEqual(url, "https://api.flickr.com/services/rest")
        XCTAssertEqual(queryParameters, [
            "method":"flickr.photos.search",
            "api_key": "12345",
            "format": "json",
            "nojsoncallback": "1",
            "text": text,
            "page": "1",
            "per_page": "1"
        ])
    }
}
