//
//  RemoteQiitaLoader.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2020/01/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation
import QiitaFeature

public final class RemoteQiitaLoader: PaginationQiitaLoader {
    private struct Pagination {
        let nextURL: URL
    }

    enum QueryKey {
        static let pageNumber = "page"
        static let perPageItemsCount = "per_page"
    }

    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private var pagination: Pagination?
    private(set) var shouldLoadNext = false

    let client: HTTPClient
    let baseURL: URL
    let perPageItemsCount: Int
    public init(client: HTTPClient, baseURL: URL, perPageItemsCount: Int) {
        self.client = client
        self.baseURL = baseURL
        self.perPageItemsCount = perPageItemsCount
    }

    public func loadNext(completion: @escaping Completion) {
        guard let urlWithQuery = constructURL(url: baseURL) else {
            assertionFailure("can not construct url from \(baseURL)")
            return
        }
        get(from: urlWithQuery) { [weak self] result in
            guard let self = self else {
                return
            }

            guard let items = try? result.get() else {
                completion(result)
                return
            }
            self.shouldLoadNext = items.count >= self.perPageItemsCount
            completion(result)
        }
    }

    public func refresh(completion: @escaping Completion) {
        self.pagination = nil
        get(from: baseURL, completion: completion)
    }

    private func get(from url: URL, completion: @escaping Completion) {
        client.get(from: url) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let data, let response):
                let result = self.handleResult(data: data, response: response)
                completion(result)
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private func handleResult(data: Data, response: HTTPURLResponse) -> PaginationQiitaLoader.Result {
        setPagination(from: response)

        do {
            let items = try QiitaAPIDecoder.decode(from: data)
            return .success(items)
        } catch {
            return .failure(Error.invalidData)
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
            QueryKey.perPageItemsCount: perPageItemsCount
        ])
        return component.url
    }

    private func makeQueryItem(from parameter: [String: Any]) -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        parameter.forEach { key, value in
            let string = String(describing: value)
            guard !string.isEmpty else { return }
            let value = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            items.append(URLQueryItem(name: key, value: value))
        }
        return items
    }
}
