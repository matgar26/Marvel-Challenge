//
//  Charecter.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/10/21.
//

import Foundation
import CoreData

struct CharacterDTO: Decodable, Hashable {
    var id: Int
    var name: String?
    var description: String?
    var profileURL: String?
    var imageURL: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description
        case thumbnail, path
        case ext = "extension"
        case urls, url, type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(.name)

        if let safeDescription: String = try container.decodeIfPresent(.description), !safeDescription.isEmpty {
            description = safeDescription
        }
        
        if let thumbnailContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .thumbnail),
           let path: String = try thumbnailContainer.decodeIfPresent(.path),
           let ext: String = try thumbnailContainer.decodeIfPresent(.ext) {
            imageURL = "\(path.replacingOccurrences(of: "http", with: "https")).\(ext)"
        }
        
        let urls: [URLWrapper]? = try container.decodeIfPresent(.urls)
        profileURL = urls?.first(where: { $0.type == "detail" })?.url
    }
    
    struct URLWrapper: Decodable {
        var type: String
        var url: String
    }
}


class CharacterNSManagedObject: NSManagedObject {
 
    @NSManaged var id: NSNumber
    @NSManaged var name: String?
    @NSManaged var characterDescription: String?
    @NSManaged var profileURL: String?
    @NSManaged var imageURL: String?

    func update(with character: CharacterDTO) {
        self.id = NSNumber(value: character.id)
        self.name = character.name
        self.characterDescription = description
        self.profileURL = character.profileURL
        self.imageURL = character.imageURL
    }
}
