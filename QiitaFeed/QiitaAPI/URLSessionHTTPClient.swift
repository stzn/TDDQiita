//
//  URLSessionHTTPClient.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

import Foundation

extension URLSessionDataTask: HTTPClientTask {}

final class URLSessionHTTPClient: HTTPClient {
    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
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
