//
//  MarvelEndpoint.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/9/21.
//

import Foundation
import Combine

enum MarvelEndpoint {
    case charecterList(offset: Int)
    case searchCharecterList(search: String?)
    case charecterDetail(charecterId: Int)
}

extension MarvelEndpoint: RequestBuilder {

    var urlComponents: URLComponents? {
        switch self {
        case .charecterList(let offset):
            return URLComponents(string: "\(Environment.baseURLString)characters?offset=\(offset)")
        case .searchCharecterList(let search):
            if let search = search {
                return URLComponents(string: "\(Environment.baseURLString)characters?nameStartsWith=\(search)")
            } else {
                return URLComponents(string: "\(Environment.baseURLString)characters?offset=0")
            }
        case .charecterDetail(let id):
            return URLComponents(string: "\(Environment.baseURLString)characters/\(id)")
        }
    }
}

protocol MarvelService {
    var apiSession: APIService {get}
    
    func getCharecterList(offset: Int) -> AnyPublisher<CharecterListWrapper, APIError>
    func searchCharecterList(search: String?) -> AnyPublisher<CharecterListWrapper, APIError>
    func getCharecterDetail(id: Int) -> AnyPublisher<CharacterDTO, APIError>
}

extension MarvelService {
    func getCharecterList(offset: Int) -> AnyPublisher<CharecterListWrapper, APIError> {
        return apiSession.request(with: MarvelEndpoint.charecterList(offset: offset))
            .eraseToAnyPublisher()
    }
    
    func searchCharecterList(search: String?) -> AnyPublisher<CharecterListWrapper, APIError> {
        return apiSession.request(with: MarvelEndpoint.searchCharecterList(search: search))
            .eraseToAnyPublisher()
    }
    
    func getCharecterDetail(id: Int) -> AnyPublisher<CharacterDTO, APIError> {
        return apiSession.request(with: MarvelEndpoint.charecterDetail(charecterId: id))
            .eraseToAnyPublisher()
    }
}
