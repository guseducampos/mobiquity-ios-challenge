//
//  PhotoSearchServiceTest.swift
//  mobiquity-ios-challengeTests
//
//  Created by Gustavo Campos on 29/8/21.
//

import Combine
import CombineExpectations
import Moya
@testable import mobiquity_ios_challenge
import XCTest

class PhotoSearchServiceTest: XCTestCase {
    func testPhotoSearch() throws {
        // Given
        let moyaProvider = MoyaProvider<MultiTarget>(stubClosure: MoyaProvider.immediatelyStub)
        let networkProvider = NetworkProvider(moyaProvider: moyaProvider)
        let service = PhotoSearchService(networkProvider: networkProvider)

        // When
        let record = service.photoSearch(text: "kitt", page: 1, elementsPerPage: 1).record()
        let response = try wait(for: record.next(), timeout: 2).photos

        // Then
        XCTAssertEqual(response.photo.count, 100)
        XCTAssertEqual(response.perPage, 100)
        XCTAssertEqual(response.photo.first?.id, "51408114727")
    }
}
