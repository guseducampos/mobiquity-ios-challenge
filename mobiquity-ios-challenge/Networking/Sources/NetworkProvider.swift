//
//  NetworkProvider.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 28/8/21.
//

import Combine
import Foundation
import Moya

/// Moya plugin that adds the token and the default parameters to a flickr
/// request in order to return the content in JSON format and authenticate using the
/// Token provided.
struct FlickrPlugin: PluginType {
    private let token: String

    init(token: String) {
        self.token = token
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let url = request.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return request
        }

        let parameters = [
            URLQueryItem(name: "api_key", value: token),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]

        components.queryItems?.append(contentsOf: parameters)

        var request = request
        request.url = components.url
        return request
    }
}

struct NetworkProvider {
    let moyaProvider: MoyaProvider<MultiTarget>

    func request(target: TargetType) -> AnyPublisher<Data, Error> {
        moyaProvider
            .request(target: MultiTarget(target))
            .map(\.data)
            .eraseToAnyPublisher()
    }

    func request<T: Decodable>(
        target: TargetType,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, Error> {
        request(target: target)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

extension MoyaProvider {
    func request(target: Target) -> AnyPublisher<Response, Error> {
        Future { promise in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    promise(.success(response))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension MoyaProvider where Target == MultiTarget {
    enum Constants {
        static let flickrToken = "11c40ef31e4961acf4f98c8ff4e945d7"
    }

    static var flickrProvider: MoyaProvider<MultiTarget> {
        MoyaProvider(
            plugins: [
                FlickrPlugin(token: Constants.flickrToken)
            ]
        )
    }
}

