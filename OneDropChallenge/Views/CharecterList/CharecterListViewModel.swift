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
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private var offset: Int = 0
    private var limit: Int = 0
    
    var needsNewPage: Bool = true
    
    var reloadData = PassthroughSubject<Void, Never>()
    
    var sections: [DiffableDataSection] = [DiffableDataSection.getSkeletonSections()]
    
    /// Tells our view that we are currently loading products and to not make another request at this time
    var isLoadingProducts: Bool = false
    
    init(persistentContainer: NSPersistentContainer) {
        self.apiSession = APISession()
        self.persistentContainer = persistentContainer
        offset = (try? persistentContainer.viewContext.count(for: CharacterEntity.fetchRequest())) ?? 0
    }
    
    /// This method is only ran on initial load and on a manual pull to refresh
    func refreshAll() {
        getPageOfCharecters()
    }
    
    func getPageOfCharecters() {
        isLoadingProducts = true
        let cancellable = self.getCharecterList(offset: offset)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Handle error: \(error)")
                case .finished: break
                }
            }) { [weak self] wrapper in
                
                guard let self = self else { return }

                self.limit = wrapper.limit
                self.offset += wrapper.count
                self.needsNewPage = wrapper.limit == wrapper.count

                let taskContext = self.persistentContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil
                let _ = self.syncCharacters(charactersPage: wrapper.results, taskContext: taskContext)
            }
        cancellables.insert(cancellable)
    }
    
    func syncCharacters(charactersPage: [CharacterDTO], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            let ids: [Int64] = charactersPage.map({$0.id})
            
            let matchingCharacterRequest: NSFetchRequest<NSFetchRequestResult>
            matchingCharacterRequest = NSFetchRequest(entityName: "CharacterEntity")
            matchingCharacterRequest.predicate = NSPredicate(format: "id IN %@", ids)
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingCharacterRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs

            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult

                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            
            // Create new records.
            for character in charactersPage {

                guard let characterEntity = NSEntityDescription.insertNewObject(forEntityName: "CharacterEntity", into: taskContext) as? CharacterEntity else {
                    print("Error: Failed to create a new CharacterEntity object!")
                    return
                }

                characterEntity.id = character.id
                characterEntity.name = character.name
                characterEntity.characterDescription = character.description
                characterEntity.detailURL = character.profileURL
                characterEntity.imageUrl = character.imageURL
            }

            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            self.isLoadingProducts = false
            successfull = true
            self.reloadData.send(Void())
        }
        return successfull
    }
    
    enum DiffableDataSection: Hashable {
        case charecterSection([Int64])
        case skeletonSection([SkeletonItem])
        case loadingSection(UUID) /// Used to reporesent our pagination loading cell
        
        static func getSkeletonSections() -> DiffableDataSection {
            var items = [SkeletonItem]()
            for _ in 1...10 {
                items.append(SkeletonItem())
            }
            return DiffableDataSection.skeletonSection(items)
        }
    }
}

struct SkeletonItem: Hashable {
    let id = UUID()
}
