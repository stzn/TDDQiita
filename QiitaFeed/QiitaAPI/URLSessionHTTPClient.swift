//
//  URLSessionHTTPClient.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

extension URLSessionDataTask: HTTPClientTask {}

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    public init(session: URLSession = .shared) {
        self.session = session
    }

    @discardableResult
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.noResponse))
                return
            }

            guard (200..<300) ~= response.statusCode else {
                completion(.failure(.invalidStatusCode(response.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            completion(.success((data, response)))
        }
        task.resume()
        return task
    }
}
