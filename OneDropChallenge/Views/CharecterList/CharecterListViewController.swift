//
//  ViewController.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/8/21.
//

import UIKit
import Combine
import CoreData

class CharecterListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var searchController: UISearchController!
    private var cancellables = [AnyCancellable?]()
    private let viewModel: CharecterListViewModel = CharecterListViewModel()
    private lazy var dataSource = createDataSource()
    
    private var searchSelection = PassthroughSubject<CharacterDTO, Never>()
    
    var searchTextTimer: Timer?
    var currentlySelectedIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        setupNavBar()
        setupCollectionView()
        setBindings()
        
        applySnapshot() // This will initially set our loading skeleton views
        refreshAll()
    }
    
    private func setupNavBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = currentlySelectedIndex, traitCollection.horizontalSizeClass == .compact {
            collectionView.deselectItem(at: index, animated: true)
        }
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.delegate = self
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshAll), for: UIControl.Event.valueChanged)
        collectionView.refreshControl = refresh
        
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: "LoadingCollectionViewCell")
        collectionView.register(UINib(nibName: "CharecterCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "CharecterCollectionViewCell")
    }
    
    private func setBindings() {
        let reloadCancellable = viewModel.reloadData.receive(on: DispatchQueue.main).sink() { [weak self] _ in
            self?.collectionView.refreshControl?.endRefreshing()
            self?.applySnapshot(animatingDifferences: false)
        }
        
        let searchSelectionSubscriber = self.searchSelection.receive(on: DispatchQueue.main).sink() { [weak self] character in
            self?.showCharacterDetail(character)
        }
        
        cancellables.append(reloadCancellable)
        cancellables.append(searchSelectionSubscriber)
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: ViewControllerManager.shared.charecterSearchResultsController(searchSelection: self.searchSelection))
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Seach Characters"
    }
    
    @objc private func refreshAll() {
        viewModel.refreshAll()
    }
}

extension CharecterListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchController.showsSearchResultsController = true
            searchTextTimer?.invalidate()
            // Throttle the search the frequency of making the search networking request so that we hopefully dont run the request until the user has finished typing their search
            searchTextTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSearch), userInfo: nil, repeats: false)
            RunLoop.current.add(searchTextTimer!, forMode: RunLoop.Mode.common)
        } else {
            if let resultsController = searchController.searchResultsController as? CharacterSearchResultsViewController {
                resultsController.viewModel.reset()
            }
            searchController.showsSearchResultsController = false
            return
        }
    }
    
    @objc func updateSearch() {
        if let resultsController = searchController.searchResultsController as? CharacterSearchResultsViewController {
            resultsController.viewModel.searchCharecters(query: searchController.searchBar.text)
        }
    }
}

// MARK: - SplitView Delegate
extension CharecterListViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {

        guard let nav = secondaryViewController as? UINavigationController, let detailViewController = nav.topViewController as? CharacterDetailViewController else {
            return false
        }
        
        // This will be nil when first launching the app
        return detailViewController.character == nil
    }
}

// MARK: - DiffableDataSource and Delegate
extension CharecterListViewController: UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    typealias DataSource = UICollectionViewDiffableDataSource<CharecterListViewModel.DiffableDataSection, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<CharecterListViewModel.DiffableDataSection, AnyHashable>
    
    func createDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case is UUID:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
                cell.startAnimating()
                return cell
            case let x as CharacterDTO:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharecterCollectionViewCell", for: indexPath) as! CharecterCollectionViewCell
                cell.configure(with: x)
                return cell
            case is SkeletonItem:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharecterCollectionViewCell", for: indexPath) as! CharecterCollectionViewCell
                cell.configure()
                return cell
//            case let id as NSManagedObjectID:
//                guard let object = try? managedObjectContext.existingObject(with: objectID) else {
//                    fatalError("Managed object should be available")
//                }
            default: fatalError()
            }
        })
        
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(viewModel.sections)
        for section in viewModel.sections {
            switch section {
            case .charecterSection(let items):
                snapshot.appendItems(items, toSection: section)
            case .skeletonSection(let items):
                snapshot.appendItems(items, toSection: section)
            case .loadingSection(let item):
                snapshot.appendItems([item], toSection: section)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    
    /// Infinate Scrolling
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let _ = cell as? LoadingCollectionViewCell {
            if !viewModel.isLoadingProducts { // Ensure we arent currently loading a page
                viewModel.getPageOfCharecters()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch dataSource.itemIdentifier(for: indexPath) {
        case let character as CharacterDTO:
            currentlySelectedIndex = indexPath
            self.showCharacterDetail(character)
        default: break
        }
    }
    
    private func showCharacterDetail( _ character: CharacterDTO) {
        let vc = ViewControllerManager.shared.characterDetailViewController(character: character)
        self.splitViewController?.showDetailViewController(vc, sender: self)
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//        guard let dataSource = collectionView?.dataSource as? DataSource else {
//            assertionFailure("The data source has not implemented snapshot support while it should")
//            return
//        }
//        
//        var snapshot = snapshot as Snapshot
//        let currentSnapshot = dataSource.snapshot() as Snapshot
//        
//        let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
//            guard let identifier = itemIdentifier as? NSManagedObjectID, let currentIndex = currentSnapshot.indexOfItem(identifier), let index = snapshot.indexOfItem(identifier), index == currentIndex else {
//                return nil
//            }
//            guard let existingObject = try? controller.managedObjectContext.existingObject(with: identifier), existingObject.isUpdated else { return nil }
//            return identifier
//        }
//        
//        snapshot.reloadItems(reloadIdentifiers)
//        
//        let shouldAnimate = collectionView?.numberOfSections != 0
//        dataSource.apply(snapshot as Snapshot, animatingDifferences: shouldAnimate)
//    }
}

// MARK: - Compositional Layout
extension CharecterListViewController {
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let compLayout = UICollectionViewCompositionalLayout { [weak self] (section, layoutEnviroment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }

            let traitCollection = layoutEnviroment.traitCollection

            switch self.viewModel.sections[section] {
            case .charecterSection( _), .skeletonSection( _):
                return self.createCharecterSection(traitCollection: traitCollection)
            case .loadingSection(_):
                return self.createLoadingSection()
            }
        }
        
        return compLayout
    }
    
    private func createCharecterSection(traitCollection: UITraitCollection) -> NSCollectionLayoutSection {
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
    
    private func createLoadingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
}
