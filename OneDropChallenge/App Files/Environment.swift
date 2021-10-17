//
//  Environment.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/9/21.
//

import Foundation

public enum Environment {
        
    // MARK: - From Configuration Files
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
          fatalError("Plist file not found")
        }
        return dict
    }()

    static let baseURLString: String = {
        guard let baseURLString = Environment.infoDictionary["BASE_URL"] as? String else {
          fatalError("Base URL not set in plist for this environment")
        }
        return baseURLString
    }()
    
    static let privateKeyString: String = {
        guard let privateKeyString = Environment.infoDictionary["PRIVATE_KEY"] as? String else {
          fatalError("Private key not set in plist for this environment")
        }
        return privateKeyString
    }()
    
    static let publicKeyString: String = {
        guard let publicKeyString = Environment.infoDictionary["PUBLIC_KEY"] as? String else {
          fatalError("Public key not set in plist for this environment")
        }
        return publicKeyString
    }()
}
