//
//  CharacterSearchResultsViewModel.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/15/21.
//

import Foundation
import Combine
import CoreData

class CharacterSearchResultsViewModel: MarvelService {
    internal var apiSession: APIService
    private var cancellables = Set<AnyCancellable>()
    
    var reloadData = PassthroughSubject<Void, Never>()
    var showEmptyState = PassthroughSubject<Bool, Never>()

    var items: [DiffableDataItem] = DiffableDataItem.getSkeletonItems()
    
    init(apiSession: APIService = APISession()) {
        self.apiSession = apiSession
    }
    
    func reset() {
        showEmptyState.send(false)
        items = DiffableDataItem.getSkeletonItems()
        self.reloadData.send(Void())
    }
    
    func searchCharecters(query: String?) {
        let cancellable = self.searchCharecterList(search: query)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error): print("Handle error: \(error)")
                case .finished: break
                } 
            }) { [weak self] wrapper in
                guard let self = self else { return }
                self.items = wrapper.results.map({DiffableDataItem.character($0)})
                self.showEmptyState.send(self.items.isEmpty)
                self.reloadData.send(Void())
            }
        cancellables.insert(cancellable)
    }
    
    enum DiffableDataItem: Hashable {
        case character(CharacterDTO)
        case skeleton(SkeletonItem)
        
        static func getSkeletonItems() -> [DiffableDataItem] {
            var items = [DiffableDataItem]()
            for _ in 0...10 {
                items.append(DiffableDataItem.skeleton(SkeletonItem()))
            }
            return items
        }
    }
}
