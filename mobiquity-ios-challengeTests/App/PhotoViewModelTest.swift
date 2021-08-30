//
//  PhotoViewModelTest.swift
//  mobiquity-ios-challengeTests
//
//  Created by Gustavo Campos on 30/8/21.
//

@testable import mobiquity_ios_challenge
import XCTest

class PhotoViewModelTest: XCTestCase {
    func testPhotoURL() throws {
        // Given
        let photo = Photo(
            id: "1234",
            owner: "test",
            secret: "567",
            server: "90",
            farm: 89,
            title: "test",
            isPublic: 0,
            isFriend: 0,
            isFamily: 0
        )

        let viewModel = try XCTUnwrap(
            PhotoViewModel(photo: photo)
        )

        // When
        let url = viewModel.url

        // Then
        let expectedUrl = try XCTUnwrap(
            URL(string: "https://farm89.static.flickr.com/90/1234_567.jpg")
        )

        XCTAssertEqual(url, expectedUrl)
    }
}
