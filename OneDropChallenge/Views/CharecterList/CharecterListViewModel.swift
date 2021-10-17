//
//  CharecterListViewModel.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/11/21.
//

import Foundation
import Combine
import CoreData

class CharecterListViewModel: MarvelService {
    internal var apiSession: APIService
    private var cancellables = Set<AnyCancellable>()
    
    private var persistentContainer: NSPersistentContainer!
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private var unfilteredList: [CharacterDTO] = []
    private var filteredList: [CharacterDTO] = []
    
    var reloadData = PassthroughSubject<Void, Never>()
    
    var sections: [DiffableDataSection] = [DiffableDataSection.getSkeletonSections()]
    
    /// Tells our view that we are currently loading products and to not make another request at this time
    var isLoadingProducts: Bool = false
    
    init(apiSession: APIService = APISession()) {
        self.apiSession = apiSession
    }
    
    /// This method is only ran on initial load and on a manual pull to refresh
    func refreshAll() {
        // Reset our currently stored products
        unfilteredList = []
        getPageOfCharecters()
    }
    
    func getPageOfCharecters() {
        isLoadingProducts = true
        let cancellable = self.getCharecterList(offset: unfilteredList.count)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Handle error: \(error)")
                case .finished: break
                }
            }) { [weak self] wrapper in
                
                guard let self = self else { return }
                var tempSections = [DiffableDataSection]()
                self.unfilteredList.append(contentsOf: wrapper.results)
                tempSections.append(.charecterSection(self.unfilteredList))
                
                if wrapper.count == wrapper.limit {
                    tempSections.append(.loadingSection(UUID()))
                }
                
                self.sections = tempSections
                self.isLoadingProducts = false
                self.reloadData.send(Void())
            }
        cancellables.insert(cancellable)
    }
    
    enum DiffableDataSection: Hashable {
        case charecterSection([CharacterDTO])
        case skeletonSection([SkeletonItem])
        case loadingSection(UUID) /// Used to reporesent our pagination loading cell
        
        static func getSkeletonSections() -> DiffableDataSection {
            var items = [SkeletonItem]()
            for _ in 0...10 {
                items.append(SkeletonItem())
            }
            return DiffableDataSection.skeletonSection(items)
        }
    }
}

struct SkeletonItem: Hashable {
    let id = UUID()
}
