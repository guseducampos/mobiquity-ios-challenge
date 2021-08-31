//
//  RecentSearchListViewModel.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 30/8/21.
//

import Combine
import CombineExt
import Foundation

final class RecentSearchListViewModel: ObservableObject {
    @Published var searchItems: [SearchItem] = []

    private let service: SearchItemServiceClient

    private var cancellable: AnyCancellable?

    init(service: SearchItemServiceClient) {
        self.service = service
    }

    func getSearchItems() {
        cancellable = service
            .getRecentItems()
            .assign(to: \.searchItems, on: self, ownership: .weak)
    }
}
