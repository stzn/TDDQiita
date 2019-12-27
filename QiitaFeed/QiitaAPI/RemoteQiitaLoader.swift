//
//  RemoteQiitaLoader.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

import QiitaFeature

final class RemoteQiitaLoader: QiitaLoader {
    private struct Pagination {
        let nextURL: URL
    }

    enum QueryKey {
        static let pageNumber = "page"
        static let perPageCount = "per_page"
    }

    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private var pagination: Pagination?
    
    let perPageCount = 30
    let url: URL
    let client: HTTPClient
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load(completion: @escaping (QiitaLoader.Result) -> Void) {
        guard let urlWithQuery = constructURL(url: url) else {
            assertionFailure("can not construct url from \(self.url)")
            return
        }
        get(from: urlWithQuery, completion: completion)
    }

    private func get(from url: URL, completion: @escaping (QiitaLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            switch result {
            case .success(let data, let response):
                do {
                    let items = try JSONDecoder().decode([QiitaItem].self, from: data)
                    self?.setPagination(from: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(Error.invalidData))
                }
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private func setPagination(from response: HTTPURLResponse) {
        guard let link = response.findLink(relation: "next"),
            let nextURL = URL(string: link.uri) else {
                return
        }
        pagination = Pagination(nextURL: nextURL)
    }

    private func constructURL(url: URL) -> URL? {
        if let pagination = pagination {
            return pagination.nextURL
        }

        guard var component = URLComponents(string: url.absoluteString) else {
            return url
        }
        component.queryItems = makeQueryItem(from: [
            QueryKey.pageNumber: 1,
            QueryKey.perPageCount: perPageCount,
        ])
        return component.url
    }

    private func makeQueryItem(from parameter: [String:Any]) -> [URLQueryItem] {
        var items :[URLQueryItem] = []
        parameter.forEach { key, value in
            let string = String(describing: value)
            guard !string.isEmpty else { return }
            let value = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            items.append(URLQueryItem(name: key, value: value))
        }
        return items
    }
}
