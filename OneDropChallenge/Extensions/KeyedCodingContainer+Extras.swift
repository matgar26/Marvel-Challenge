//
//  KeyedCodingContainer+Extras.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/10/21.
//

import Foundation

extension KeyedDecodingContainer {
    public func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
        return try? decodeIfPresent(T.self, forKey: key)
    }
}
