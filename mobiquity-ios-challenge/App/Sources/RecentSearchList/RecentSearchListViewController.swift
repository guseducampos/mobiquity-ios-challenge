//
//  RecentSearchListVIewController.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 30/8/21.
//

import Combine
import CombineCocoa
import SwiftUI
import UIKit

class RecentSearchListViewController: UIViewController {
    // MARK - View Elements
    private var resultViewController = PhotoGridViewController()

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(
            searchResultsController: resultViewController
        )
        searchController.searchResultsUpdater = self
        searchController.searchBar.returnKeyType = .search
        searchController.showsSearchResultsController = true
        searchController.searchBar.delegate = self
        return searchController
    }()

    // MARK - Dependencies
    private let viewModel: PhotoSearchViewModel
    private let recentSearchViewModel: RecentSearchListViewModel
    private var cancellables: Set<AnyCancellable> = []

    // MARK - Subjects
    private let searchSubject: PassthroughSubject<String, Never> = .init()

    init(
        viewModel: PhotoSearchViewModel,
        recentSearchViewModel: RecentSearchListViewModel
    ) {
        self.viewModel = viewModel
        self.recentSearchViewModel = recentSearchViewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        binding()
        recentSearchViewModel.getSearchItems()

    }

    private func setupView() {
        view.backgroundColor = .white
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        let recentSearchListView = RecentSearchListView(viewModel: recentSearchViewModel) {[weak self] item in
            self?.searchBy(recent: item)
        }

        let hostingController = UIHostingController(rootView: recentSearchListView)

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .white
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)

    }

    private func binding() {
        let output = viewModel.transform(
            input: .init(
                searchImage: searchSubject.eraseToAnyPublisher(),
                nextPage: resultViewController.reachedBottomPublisher
            )
        )

        output
            .photos
            .sink {[weak self] photosSlice in
                guard let self = self else {
                    return
                }
                self.resultViewController.updatePhotos(
                    photosSlice.viewModel,
                    isNewSearch: photosSlice.isNewSearch
                )
            }
            .store(in: &cancellables)

        output
            .paginationState
            .sink {[weak self] state in
                self?.resultViewController.updatePaginationState(state: state)
            }
            .store(in: &cancellables)
    }

    private func searchBy(recent: SearchItem) {
        searchController.searchBar.text = recent.name
        searchController.searchBar.becomeFirstResponder()
        searchSubject.send(recent.name)
    }

    private func clearResults() {
        resultViewController.clearAll()
        cancellables = []
        binding()
    }
}

extension RecentSearchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

extension RecentSearchListViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Send event when user taps into search keyboard's button
        if let text = searchBar.text {
            searchSubject.send(text)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        recentSearchViewModel.getSearchItems()
        clearResults()
    }
}
