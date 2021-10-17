//
//  CharacterSearchResultsViewController.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/15/21.
//

import UIKit
import Combine

class CharacterSearchResultsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var cancellables = [AnyCancellable?]()
    let viewModel: CharacterSearchResultsViewModel = CharacterSearchResultsViewModel()
    private lazy var dataSource = createDataSource()
    
    init() {
        super.init(nibName: "CharacterSearchResultsViewController", bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setBindings()
        
        applySnapshot() // This will initially set our loading skeleton views
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.backgroundView = SearchEmptyStateView()
        collectionView.backgroundView?.isHidden = true
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CharecterCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CharecterCollectionViewCell")
    }
    
    private func setBindings() {
        let reloadCancellable = viewModel.reloadData.receive(on: DispatchQueue.main).sink() { [weak self] _ in
            self?.collectionView.refreshControl?.endRefreshing()
            self?.applySnapshot(animatingDifferences: false)
        }
        
        let emptyStateCancellable = viewModel.showEmptyState.receive(on: DispatchQueue.main).sink() { [weak self] shouldShow in
            self?.collectionView.backgroundView?.isHidden = !shouldShow
        }
        
        cancellables.append(reloadCancellable)
        cancellables.append(emptyStateCancellable)
    }
}

extension CharacterSearchResultsViewController: UICollectionViewDelegate {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, CharacterSearchResultsViewModel.DiffableDataItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, CharacterSearchResultsViewModel.DiffableDataItem>
    
    func createDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharecterCollectionViewCell", for: indexPath) as! CharecterCollectionViewCell
            switch item {
            case .character(let character):
                cell.configure(with: character)
            case .skeleton(_):
                cell.configure()
            }
            return cell
        })
        
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.items, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .character(let character): break
        default: break
        }
    }
}

// MARK: - Compositional Layout
extension CharacterSearchResultsViewController {
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let compLayout = UICollectionViewCompositionalLayout { (section, layoutEnviroment) -> NSCollectionLayoutSection? in
            let sectionInsetConstant: CGFloat = 16
            let sectionInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: sectionInsetConstant, leading: sectionInsetConstant, bottom: sectionInsetConstant, trailing: sectionInsetConstant)

            let item = NSCollectionLayoutItem(layoutSize:  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(190)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(190)), subitem: item, count: 2)
            group.interItemSpacing = .fixed(16)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = sectionInset
            section.interGroupSpacing = 16
            return section
        }
        
        return compLayout
    }
}

