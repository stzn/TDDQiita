//
//  HTTPClient.swift
//  QiitaFeed
//
//  Created by Shinzan Takata on 2019/12/15.
//  Copyright © 2019 shiz. All rights reserved.
//

enum HTTPClientError: Error {
    case noResponse
    case invalidStatusCode(Int)
    case noData
    case unknown(Error)
}

protocol HTTPClientTask {
    func cancel()
}

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), HTTPClientError>
    typealias Completion = (Result) -> Void

    @discardableResult
    func get(from url: URL, completion: @escaping Completion) -> HTTPClientTask
}
