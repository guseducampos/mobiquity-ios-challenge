//
//  PhotoViewModel.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 30/8/21.
//

import Foundation

struct PhotoViewModel: Hashable {
    private let id: UUID = UUID() // Provide uniqueness in case the same image is found it twice
    let photo: Photo
    let url: URL

    init?(photo: Photo) {
        self.photo = photo
        let urlString = "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"

        guard let url = URL(string: urlString) else {
            return nil
        }

        self.url = url
    }
}
