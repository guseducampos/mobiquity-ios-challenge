//
//  PhotoGridViewController.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 30/8/21.
//

import Combine
import UIKit

class PhotoGridViewController: UIViewController {
    // MARK - Nested Types
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PhotoViewModel>

    enum Section {
        case main
    }

    // MARK - Constants
    private let cellIdentifier = "PhotoCellImage"

    // MARK - UI Elements
    private let collectionLayout: UICollectionViewLayout = {
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                heightDimension: .fractionalHeight(1.0))
        let layoutItem = NSCollectionLayoutItem(layoutSize: layoutSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize =  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalWidth(0.5))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }()

    private let bottomActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private let topActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private let topErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.text = "An error occurred trying to fetch the images"
        label.isHidden = true
        label.textColor = .red
        return label
    }()

    private let bottomErrorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.text = "An error occurred trying to fetch the images"
        label.isHidden = true
        label.textColor = .red
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

   private lazy var dataSource: UICollectionViewDiffableDataSource<Section, PhotoViewModel> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, PhotoViewModel>(
            collectionView: self.collectionView) { collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath)

            if let cell = cell as? PhotoCollectionViewCell {
                cell.setupImage(viewModel: viewModel)
            }

            return cell
        }

        return dataSource
    }()

    var reachedBottomPublisher: AnyPublisher<Void, Never> {
        collectionView.reachedBottomPublisher()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

       setupView()
    }

    func setupView() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(bottomActivityIndicator)
        view.addSubview(topActivityIndicator)
        view.addSubview(topErrorLabel)
        view.addSubview(bottomErrorLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            bottomActivityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bottomActivityIndicator.bottomAnchor, constant: 15),

            topActivityIndicator.safeAreaLayoutGuide.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            topActivityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),

            bottomErrorLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bottomErrorLabel.bottomAnchor, constant: 15),
            bottomErrorLabel.heightAnchor.constraint(equalToConstant: 15),

            topErrorLabel.safeAreaLayoutGuide.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            topErrorLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            topErrorLabel.heightAnchor.constraint(equalToConstant: 15)
        ])

        collectionView.register(PhotoCollectionViewCell.self,
                                forCellWithReuseIdentifier: cellIdentifier)

        collectionView.keyboardDismissMode = .onDrag
    }

    func updatePhotos(_ photos: [PhotoViewModel], isNewSearch: Bool) {
        if isNewSearch {
            var snapshot =  Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(photos)
            dataSource.apply(snapshot, animatingDifferences: true)
        } else {
            var snapshot = dataSource.snapshot()
            snapshot.appendItems(photos, toSection: .main)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    func updatePaginationState(state: PhotoSearchViewModel.PaginationState) {

        switch state.loadingState {
        case .idle:
            bottomActivityIndicator.performAnimation(false)
            topActivityIndicator.performAnimation(false)
            collectionView.contentInset.top = 0
            collectionView.contentInset.bottom = 0
            topErrorLabel.isHidden = true
            bottomErrorLabel.isHidden = true
        case .loading:
            topErrorLabel.isHidden = true
            bottomErrorLabel.isHidden = true
            if state.isNewSearch {
                collectionView.contentInset.top = 50
                topActivityIndicator.performAnimation(true)
                bottomActivityIndicator.performAnimation(false)
            } else {
                bottomActivityIndicator.performAnimation(true)
                topActivityIndicator.performAnimation(false)
                collectionView.contentInset.bottom = 50
            }
        case .failure:
            bottomActivityIndicator.performAnimation(false)
            topActivityIndicator.performAnimation(false)

            if state.isNewSearch {
                collectionView.contentInset.top = 50
                topErrorLabel.isHidden = false
            } else {
                bottomErrorLabel.isHidden = false
                collectionView.contentInset.bottom = 50
            }
        }
    }

    func clearAll() {
        updatePhotos([], isNewSearch: true)
    }
}
