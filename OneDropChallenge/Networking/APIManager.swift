//
//  APIManager.swift
//  OneDropChallenge
//
//  Created by Matt Gardner on 10/9/21.
//

import Foundation
import Combine
import CryptoKit

protocol APIService {
    func request<T: Decodable>(with builder: RequestBuilder) -> AnyPublisher<T, APIError>
}

protocol RequestBuilder {
    var urlComponents: URLComponents? { get }
}

enum APIError: Error {
    case decodingError
    case httpError(Int)
    case unknown
}

struct APISession: APIService {
        
    func createAuthParams() -> [URLQueryItem] {
        let timeStamp = Date().timeIntervalSince1970.description
        let privateKey = Environment.privateKeyString
        let publicKey = Environment.publicKeyString
        
        let hashString = "\(timeStamp)\(privateKey)\(publicKey)"
        guard let data = hashString.data(using: .utf8) else { preconditionFailure("Invalid API Token") }
        
        let digest = Insecure.MD5.hash(data: data)
            .map {String(format: "%02x", $0)}
            .joined()
        
        return [URLQueryItem(name: "ts", value: timeStamp), URLQueryItem(name: "apikey", value: publicKey), URLQueryItem(name: "hash", value: digest)]
    }
    
    func request<T>(with builder: RequestBuilder) -> AnyPublisher<T, APIError> where T: Decodable {
        var components = builder.urlComponents
        components?.queryItems?.append(contentsOf: self.createAuthParams())
        guard let url = components?.url else { preconditionFailure() }
        let request = URLRequest(url: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .mapError { _ in .unknown }
            .flatMap { data, response -> AnyPublisher<T, APIError> in
                guard let response = response as? HTTPURLResponse else { return Fail(error: APIError.unknown).eraseToAnyPublisher() }
                if (200...299).contains(response.statusCode) {
                    return Just(data)
                        .decode(type: T.self, decoder: decoder)
                        .mapError {_ in .decodingError}
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: APIError.httpError(response.statusCode))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
