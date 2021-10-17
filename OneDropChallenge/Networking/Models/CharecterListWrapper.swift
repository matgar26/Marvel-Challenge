//
//  CharecterListWrapper.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/11/21.
//

import Foundation

struct CharecterListWrapper: Decodable, Hashable {
    var offset: Int
    var limit: Int
    var total: Int
    var count: Int
    var results: [CharacterDTO]
    
    private enum CodingKeys: String, CodingKey {
        case data, offset, limit, total, count, results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        offset = try dataContainer.decode(Int.self, forKey: .offset)
        limit = try dataContainer.decode(Int.self, forKey: .limit)
        total = try dataContainer.decode(Int.self, forKey: .total)
        count = try dataContainer.decode(Int.self, forKey: .count)
        results = try dataContainer.decode([CharacterDTO].self, forKey: .results)
    }
}
