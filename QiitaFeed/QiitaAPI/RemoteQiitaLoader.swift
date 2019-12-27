//
//  RemoteQiitaLoader.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

final class RemoteQiitaLoader: QiitaLoader {

    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    let url: URL
    let client: HTTPClient
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (QiitaLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let data, let response):
                do {
                    let items = try JSONDecoder().decode([QiitaItem].self, from: data)
                    completion(.success(items))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
